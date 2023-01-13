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
/// For more information, see <doc:05-Queryable>.
@propertyWrapper
public struct Queryable<Result>: DynamicProperty {

    /// A representation of the `Queryable` property wrapper type. This can be passed to ``Puddles/QueryControlled``.
    public struct Wrapper {

        /// A binding to the `isActive` state inside the `@Queryable` property wrapper.
        ///
        /// This is used internally inside ``Puddles/Queryable/Wrapper/query()``.
        var isActive: Binding<Bool>

        /// A pointer to the ``Puddles/Queryable/Resolver`` object that is passed inside the closure of the ``Puddles/QueryControlled`` navigation wrapper.
        ///
        /// This is used internally inside ``Puddles/QueryControlled``.
        var resolver: Resolver

        /// A property that stores the `Result` type to be used in logging messages.
        let expectedType: Result.Type

        /// A pointer to the `Buffer` object type.
        ///
        /// This is used internally inside ``Puddles/Queryable/Wrapper/query()``.
        private var buffer: Buffer

        /// A representation of the `Queryable` property wrapper type. This can be passed to ``Puddles/QueryControlled``.
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

        /// Requests the collection of data by starting a query on the `Result` type.
        ///
        /// This method will suspend for as long as the query is unanswered and not cancelled. When the parent Task is cancelled, this method will immediately cancel the query and throw a ``Puddles/QueryError/queryCancelled`` error.
        ///
        /// Creating multiple queries at the same time will cause a query conflict which is resolved using the ``Puddles/Queryable/QueryConflictPolicy`` defined in the initializer of ``Puddles/Queryable``. The default policy is ``Puddles/Queryable/QueryConflictPolicy/cancelNewQuery``.
        /// - Returns: The result of the query.
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

    /// Boolean flag indicating if the query has started, which usually coincides with a presentation being shown in a ``Puddles/Coordinator``.
    @State var isActive: Bool = false

    public var wrappedValue: Wrapper {
        .init(isActive: $isActive, expectedType: Result.self, resolver: resolver, buffer: buffer)
    }

    /// Internal helper type that stores and continues a `CheckedContinuation` created by calling ``Puddles/Queryable/Wrapper/query()``.
    private var buffer: Buffer

    /// Helper type to hide implementation details of ``Puddles/Queryable``.
    /// This type exposes convenient methods to answer (i.e. complete) a query.
    private var resolver: Resolver!

    public init(queryConflictPolicy: QueryConflictPolicy = .cancelNewQuery) {
        buffer = Buffer(queryConflictPolicy: queryConflictPolicy)
        resolver = .init(answerHandler: resumeContinuation(returning:), errorHandler: resumeContinuation(throwing:))
    }

    /// Completes the query with a result.
    /// - Parameter result: The answer to the query.
    private func resumeContinuation(returning result: Result) {
        Task {
            await buffer.resumeContinuation(returning: result)
        }
    }

    /// Completes the query with an error.
    /// - Parameter result: The error that should be thrown.
    private func resumeContinuation(throwing error: Error) {
        Task {

            // Catch an unanswered query and cancel it to prevent the stored continuation from leaking.
            if case QueryInternalError.queryAutoCancel = error,
               await buffer.hasContinuation {
                logger.notice("Cancelling query of »\(Result.self, privacy: .public)« because presentation has terminated.")
                await buffer.resumeContinuation(throwing: QueryError.queryCancelled)
                return
            }

            await buffer.resumeContinuation(throwing: error)
        }
    }
}

extension Queryable {

    /// A query conflict resolving strategy for situations in which multiple queries are started at the same time.
    public enum QueryConflictPolicy {

        /// A query conflict resolving strategy that cancels the previous, ongoing query to allow the new query to continue.
        case cancelPreviousQuery

        /// A query conflict resolving strategy that cancels the new query to allow the previous, ongoing query to continue.
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
