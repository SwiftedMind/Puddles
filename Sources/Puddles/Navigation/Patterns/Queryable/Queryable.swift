import SwiftUI

/// A type that can be used to query the collection of some kind of disconnected,
/// delayed data (like a `Bool` coming from a confirmation dialog view) and asynchronously `await` its retrieval in-place, without ever leaving the scope.
///
/// First, create a property of the desired data type:
///
/// ```swift
///  @Queryable<Bool> var deletionConfirmation
/// ```
///
/// Then, wrap a navigation presentation (like a confirmation dialog view) in an instance of ``Puddles/QueryControlled``, passing in the ``Puddles/Queryable`` property.
/// The ``Puddles/QueryControlled`` wrapper will provide an `isActive` binding that you can pass to your presentation.
///
/// ```swift
/// QueryControlled(by: deletionConfirmation) { isActive, query in
///   Alert(
///     title: "Do you want to delete this?",
///     isPresented: isActive
///   ) {
///     Button("Cancel", role: .cancel) {
///         query.answer(with: false)
///     }
///     Button("OK") {
///         query.answer(with: true)
///     }
///   } message: {
///     Text("This cannot be reversed!")
///   }
/// }
/// ```
///
/// To query data collection and await the results, call ``Puddles/Queryable/Wrapper/query()`` on the ``Puddles/Queryable`` property. This will activate the wrapped navigation presentation which can then answer the query at its completion point.
///
/// ```swift
/// do {
///   let shouldDelete = try await deletionConfirmation.query()
/// } catch {}
/// ```
///
/// When the Task that calls ``Puddles/Queryable/Wrapper/query()`` is cancelled, the suspended query will also cancel and deactivate (i.e. close) the wrapped navigation presentation. In that case, a ``Puddles/QueryError/queryCancelled`` error is thrown.
///
/// For more information, see <doc:05-Expectations>.
///
/// - Important: By `await`ing a ``Puddles/Queryable/Wrapper/query()`` result, you have to guarantee that an answer will be provided exactly once, no less and no more! Failing to do so will cause undefined behavior and even crashes, since this view makes use of `CheckedContinuation`s.
@propertyWrapper
public struct Queryable<Result>: DynamicProperty {

    public struct Wrapper {
        var isActive: Binding<Bool>
        var resolver: Resolver
        let expectedType: Result.Type
        private var buffer: Buffer

        fileprivate init(
            isActive: Binding<Bool>,
            expectedType: Result.Type,
            resolver: Resolver,
            buffer: Buffer
        ) {
            self.isActive = isActive
            self.expectedType = expectedType
            self.resolver = resolver
            self.buffer = buffer
        }

        public func query() async throws -> Result {
            isActive.wrappedValue = true
            return try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { continuation in
                    Task { await buffer.storeContinuation(continuation) }
                }
            } onCancel: {
                isActive.wrappedValue = false
                Task { await buffer.resumeContinuation(throwing: QueryError.queryCancelled) }
            }
        }
    }


    public var wrappedValue: Wrapper {
        .init(isActive: $isActive, expectedType: Result.self, resolver: resolver, buffer: buffer)
    }

    /// Boolean flag indicating if the expectation has started, which usually coincides with a presentation being shown in a ``Puddles/Coordinator``.
    @State var isActive: Bool = false

    /// Internal helper type that stores and continues a `CheckedContinuation` created within ``Expectation/result``.
    private var buffer: Buffer

    /// Helper type to hide other implementation details of ``Expectation``.
    /// This type only exposes a single method to complete the expectation.
    private var resolver: Resolver!

    public init(queryConflictPolicy: QueryConflictPolicy = .cancelNewQuery) {
        buffer = Buffer(queryConflictPolicy: queryConflictPolicy)
        resolver = .init(answerHandler: resumeContinuation(returning:), errorHandler: resumeContinuation(throwing:))
    }

    /// Helper flag to determine if a continuation is currently stored.
    ///
    /// This is needed for runtime checks in ``Expecting/body``
    /// to inform about unfulfilled expectations (causing a `CheckedContinuation` to leak).
    private var hasContinuation: Bool {
        get async {
            await buffer.hasContinuation
        }
    }

    // MARK: - Completion access

    /// Completes the expectation with a result.
    /// - Parameter result: The result of the expectation.
    private func resumeContinuation(returning result: Result) {
        Task {
            await buffer.resumeContinuation(returning: result)
        }
    }

    /// Completes the expectation with a result.
    /// - Parameter result: The result of the expectation.
    private func resumeContinuation(throwing error: Error) {
        Task {
            if case QueryInternalError.queryAutoCancel = error,
               await buffer.hasContinuation {
                // Unfinished continuation detected. We need to cancel it
                logger.notice("Cancelling query of »\(Result.self, privacy: .public)« because presentation has terminated.")
                await buffer.resumeContinuation(throwing: QueryError.queryCancelled)
                return
            }

            await buffer.resumeContinuation(throwing: error)
        }
    }
}

extension Queryable {

    public enum QueryConflictPolicy {
        case cancelPreviousQuery
        case cancelNewQuery
    }

    /// Internal helper type that stores the `CheckedContinuation`.
    ///
    /// To prevent data races, it is an actor.
    fileprivate final actor Buffer {
        private let queryConflictPolicy: QueryConflictPolicy
        private var continuation: CheckedContinuation<Result, Swift.Error>?

        init(queryConflictPolicy: QueryConflictPolicy) {
            self.queryConflictPolicy = queryConflictPolicy
        }

        var hasContinuation: Bool {
            continuation != nil
        }

        func storeContinuation(_ continuation: CheckedContinuation<Result, Swift.Error>) {
            if self.continuation != nil {
                switch queryConflictPolicy {
                case .cancelPreviousQuery:
                    logger.warning("Cancelling previous query of »\(Result.self, privacy: .public)« to allow new query.")
                    self.continuation?.resume(throwing: QueryError.queryCancelled)
                    self.continuation = nil
                case .cancelNewQuery:
                    logger.warning("Cancelling new query of »\(Result.self, privacy: .public)« because another query is ongoing.")
                    continuation.resume(throwing: QueryError.queryCancelled)
                    return
                }
            }

            self.continuation = continuation
        }

        func resumeContinuation(returning result: Result) {
            continuation?.resume(returning: result)
            continuation = nil
        }

        func resumeContinuation(throwing error: Error) {
            continuation?.resume(throwing: error)
            continuation = nil
        }
    }

    /// A type that lets you answer a query made by a call to ``Puddles/Queryable/Wrapper/query()``.
    public class Resolver {

        private let answerHandler: (Result) -> Void
        private let cancelHandler: (Error) -> Void

        init(
            answerHandler: @escaping (Result) -> Void,
            errorHandler: @escaping (Error) -> Void
        ) {
            self.answerHandler = answerHandler
            self.cancelHandler = errorHandler
        }

        /// Answer the query with a result.
        /// - Parameter result: The result of the query.
        public func answer(with result: Result) {
            answerHandler(result)
        }

        /// Answer the query with an optional result. If it is `nil`,  this will call ``Puddles/Queryable/Resolver/cancelQuery()``.
        /// - Parameter result: The result of the query, as an optional.
        public func answer(withOptional optionalResult: Result?) {
            if let optionalResult {
                answerHandler(optionalResult)
            } else {
                cancelQuery()
            }
        }

        /// Answer the query.
        public func answer() where Result == Void {
            answerHandler(())
        }

        /// Answer the query by throwing an error.
        /// - Parameter error: The error to throw.
        public func answer(throwing error: Error) {
            cancelHandler(error)
        }

        /// Cancel the query by throwing a ``Puddles/QueryError/queryCancelled`` error.
        public func cancelQuery() {
            cancelHandler(QueryError.queryCancelled)
        }

        /// Cancel the query by throwing a `QueryInternalError.queryAutoCancel` error.
        ///
        /// This is an internal helper method to distnguish between a user canceled query and a system-cancelled query. See ``Puddles/QueryControlled``'s ``Puddles/QueryControlled/body`` for an example.
        func cancelQueryIfNeeded() {
            cancelHandler(QueryInternalError.queryAutoCancel)
        }
    }
}

fileprivate enum QueryInternalError: Swift.Error {
    case queryAutoCancel
}

public enum QueryError: Swift.Error {
    case queryCancelled
}
