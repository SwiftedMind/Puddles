import Combine
import SwiftUI

/// A property wrapper type that can trigger a view presentation from within an `async` function and `await` its completion and potential result value.
///
/// An example use case would be a boolean coming from a confirmation dialog view. First, create a property of the desired data type:
///
/// ```swift
/// @QueryableItem<String, Bool> var deletionConfirmation
/// ```
///
/// Then, use one of the `queryable` prefixed presentation modifiers to show the deletion confirmation. Here, we use an alert:
///
/// ```swift
/// someView
///   .queryableAlert(
///     controlledBy: deletionConfirmation,
///     title: "Do you want to delete this?") { itemName, query in
///       Button("Cancel", role: .cancel) {
///         query.answer(with: false)
///       }
///       Button("OK") {
///         query.answer(with: true)
///       }
///     } message: { itemName in
///       Text("This cannot be reversed!")
///     }
/// ```
///
/// To actually present the alert and await the boolean result, call ``Puddles/QueryableItem/Trigger/query(with:)`` on the ``Puddles/QueryableItem`` property.
/// This will activate the alert presentation which can then resolve the query in its completion handler.
///
/// ```swift
/// do {
///   let item = // ...
///   let shouldDelete = try await deletionConfirmation.query(with: item.name)
/// } catch {}
/// ```
///
/// When the Task that calls ``Puddles/QueryableItem/Trigger/query(with:)`` is cancelled, the suspended query will also cancel and deactivate (i.e. close) the wrapped navigation presentation.
/// In that case, a ``Puddles/QueryCancellationError`` error is thrown.
///
/// For more information, see <doc:05-Queryable>.
@propertyWrapper
public struct QueryableItem<Item, Result>: DynamicProperty where Item: Sendable, Result: Sendable {

    /// A representation of the `Queryable` property wrapper type.
    public struct Trigger {

        /// A binding to the `item` state inside the `@QueryableItem` property wrapper.
        ///
        /// This is used internally inside ``Puddles/QueryableItem/Wrapper/query()``.
        var item: Binding<Item?>

        /// A pointer to the ``Puddles/QueryResolver`` object that is used to resolve the query.
        ///
        /// This is used in the `queryable` prefixed presentation modifiers, like `queryableSheet`.
        var resolver: QueryResolver<Result>

        /// A property that stores the `Result` type to be used in logging messages.
        var expectedType: Result.Type {
            Result.self
        }

        /// A pointer to the `Buffer` object type.
        ///
        /// This is used internally inside ``Puddles/QueryableItem/Wrapper/query()``.
        private var buffer: QueryBuffer<Result>

        /// A representation of the `Queryable` property wrapper type. This can be passed to `queryable` prefixed presentation modifiers, like `queryableSheet`.
        fileprivate init(
            item: Binding<Item?>,
            resolver: QueryResolver<Result>,
            buffer: QueryBuffer<Result>
        ) {
            self.item = item
            self.resolver = resolver
            self.buffer = buffer
        }

        /// Requests the collection of data by starting a query on the `Result` type, providing an input value.
        ///
        /// This method will suspend for as long as the query is unanswered and not cancelled. When the parent Task is cancelled, this method will immediately cancel the query and throw a ``Puddles/QueryCancellationError`` error.
        ///
        /// Creating multiple queries at the same time will cause a query conflict which is resolved using the ``Puddles/QueryConflictPolicy`` defined in the initializer of ``Puddles/QueryableItem``. The default policy is ``Puddles/QueryConflictPolicy/cancelPreviousQuery``.
        /// - Returns: The result of the query.
        public func query(with item: Item) async throws -> Result {
            return try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { continuation in
                    Task {
                        let couldStore = await buffer.storeContinuation(continuation)
                        if couldStore {
                            self.item.wrappedValue = item
                        }
                    }
                }
            } onCancel: {
                Task {
                    await buffer.resumeContinuation(throwing: QueryCancellationError())
                    self.item.wrappedValue = nil
                }
            }
        }

        /// Cancels any ongoing queries.
        public func cancel() {
            Task {
                await buffer.resumeContinuation(throwing: QueryCancellationError())
                item.wrappedValue = nil
            }
        }

        /// A flag indicating if a query is active.
        public var isQuerying: Bool {
            item.wrappedValue != nil
        }
    }

    /// Optional item storing the input value for a query and is used to indicate if the query has started, which usually coincides with a presentation being shown in a ``Puddles/Coordinator`` or ``Puddles/Navigator``.
    @State var item: Item?

    public var wrappedValue: Trigger {
        .init(item: $item, resolver: resolver, buffer: buffer)
    }

    /// Internal helper type that stores and continues a `CheckedContinuation` created by calling ``Puddles/QueryableItem/Trigger/query()``.
    private var buffer: QueryBuffer<Result>

    /// Helper type to hide implementation details of ``Puddles/QueryableItem``.
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
            item = nil
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
                item = nil
                return
            }

            await buffer.resumeContinuation(throwing: error)
            item = nil
        }
    }
}
