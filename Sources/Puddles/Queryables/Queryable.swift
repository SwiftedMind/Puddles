import Combine
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
public struct Queryable<Result>: DynamicProperty where Result: Sendable {

    /// A representation of the `Queryable` property wrapper type. This can be passed to ``Puddles/QueryControlled``.
    public struct Trigger {

        /// A binding to the `isActive` state inside the `@Queryable` property wrapper.
        ///
        /// This is used internally inside ``Puddles/Queryable/Wrapper/query()``.
        var isActive: Binding<Bool>

        /// A pointer to the ``Puddles/QueryResolver`` object that is passed inside the closure of the ``Puddles/QueryControlled`` navigation wrapper.
        ///
        /// This is used internally inside ``Puddles/QueryControlled``.
        var resolver: QueryResolver<Result>

        /// A property that stores the `Result` type to be used in logging messages.
        var expectedType: Result.Type {
            Result.self
        }

        /// A pointer to the `Buffer` object type.
        ///
        /// This is used internally inside ``Puddles/Queryable/Wrapper/query()``.
        private var buffer: QueryBuffer<Result>

        /// A representation of the `Queryable` property wrapper type. This can be passed to ``Puddles/QueryControlled``.
        fileprivate init(
            isActive: Binding<Bool>,
            resolver: QueryResolver<Result>,
            buffer: QueryBuffer<Result>
        ) {
            self.isActive = isActive
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
            return try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { continuation in
                    Task {
                        let couldStore = await buffer.storeContinuation(continuation)
                        if couldStore {
                            isActive.wrappedValue = true
                        }
                    }
                }
            } onCancel: {
                isActive.wrappedValue = false
                Task { await buffer.resumeContinuation(throwing: QueryCancellationError()) }
            }
        }

        public func cancel() {
            isActive.wrappedValue = false
            Task {
                await buffer.resumeContinuation(throwing: QueryCancellationError())
            }
        }

        public var isQuerying: Bool {
            isActive.wrappedValue
        }
    }

    /// Boolean flag indicating if the query has started, which usually coincides with a presentation being shown in a ``Puddles/Coordinator``.
    @State var isActive: Bool = false

    public var wrappedValue: Trigger {
        .init(isActive: $isActive, resolver: resolver, buffer: buffer)
    }

    public var projectedValue: Trigger {
        .init(isActive: $isActive, resolver: resolver, buffer: buffer)
    }

    /// Internal helper type that stores and continues a `CheckedContinuation` created by calling ``Puddles/Queryable/Wrapper/query()``.
    private var buffer: QueryBuffer<Result>

    /// Helper type to hide implementation details of ``Puddles/Queryable``.
    /// This type exposes convenient methods to answer (i.e. complete) a query.
    private var resolver: QueryResolver<Result> {
        .init(
            answerHandler: resumeContinuation(returning:),
            errorHandler: resumeContinuation(throwing:)
        )
    }

    public init(queryConflictPolicy: QueryConflictPolicy = .cancelNewQuery) {
        buffer = QueryBuffer(queryConflictPolicy: queryConflictPolicy)
    }

    /// Completes the query with a result.
    /// - Parameter result: The answer to the query.
    private func resumeContinuation(returning result: Result) {
        Task {
            await buffer.resumeContinuation(returning: result)
            isActive = false
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
                await buffer.resumeContinuation(throwing: QueryCancellationError())
                isActive = false
                return
            }

            await buffer.resumeContinuation(throwing: error)
            isActive = false
        }
    }
}

public struct QueryCancellationError: Swift.Error {}

public enum QueryError: Swift.Error {
    case unknown
}
