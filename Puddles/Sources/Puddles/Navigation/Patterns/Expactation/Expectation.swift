import SwiftUI

// TODO: Replace with AsyncChannel (which does exactly this, just better): https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Channel.md

/// A type that can be used to trigger the collection of some kind of disconnected, delayed data (like a `Bool` coming from a confirmation dialog view) and asynchronously `await` its retrieval in-place, without ever leaving the original scope.
///
/// Sometimes an action triggers a flow that requires user input or some form of other delayed and disconnected data to complete.
/// An example of this would be a confirmation dialog for a deletion process.
///
/// Such a dialog would typically be triggered from within a `Coordinator`'s ``Puddles/Coordinator/handleAction(_:)-38d52`` method and finished within the dialog's completion handlers. This logically separates the deletion flow and makes it harder to reason about the code.
///
/// By using an ``Expectation``, you can simply `await` the results of the dialog from right within ``Puddles/Coordinator/handleAction(_:)-38d52``.
///
/// To do this, wrap a navigation presentation (like a confirmation dialog) in an instance of ``Expecting``, passing in a binding to an ``Expectation`` instance.
/// The ``Expecting`` wrapper will provide an `isActive` binding that you can pass to your presentation.
/// Then, inside the `Coordinator`'s ``Puddles/Coordinator/handleAction(_:)-4le7d`` method,
/// you can start the presentation by calling ``Expectation/show()`` on the ``Expectation``.
/// Having done this, you can simply `await` the results of the presentation through the ``Expectation/result`` property.
/// Lastly, to finish the presentation, call ``Expectation/hide()``.
///
/// - Important: By `await`ing a ``Expectation/result``, you have to guarantee that the expectation will be completed exactly once, no less and no more! Failing to do so will cause undefined behavior and even crashes, since this view makes use of `CheckedContinuation`s.
public struct Expectation<ExpectedType> {

    /// Internal helper type that stores the `CheckedContinuation`.
    ///
    /// To prevent data races, it is an actor.
    private final actor Buffer {
        private var continuation: CheckedContinuation<ExpectedType, Never>?

        var hasContinuation: Bool {
            continuation != nil
        }

        func setContinuation(_ continuation: CheckedContinuation<ExpectedType, Never>) {
            self.continuation = continuation
        }

        func complete(with result: ExpectedType) {
            continuation?.resume(returning: result)
            continuation = nil
        }
    }

    /// Helper type to hide other implementation details of ``Puddles/Expectation``.
    /// This type only exposes a single method to complete the expectation.
    public struct Resolver {

        private let handler: (ExpectedType) -> Void

        init(handler: @escaping (ExpectedType) -> Void) {
            self.handler = handler
        }

        /// Completes the expectation with a result.
        /// - Parameter result: The result of the expectation.
        public func complete(with result: ExpectedType) {
            handler(result)
        }

        public func complete() where ExpectedType == Void {
            handler(())
        }
    }

    /// Internal helper type that stores and continues a `CheckedContinuation` created within ``Expectation/result``.
    private var buffer: Buffer

    /// Boolean flag indicating if the expectation has started, which usually coincides with a presentation being shown in a ``Puddles/Coordinator``.
    var isActive: Bool = false

    /// An optional result that needs to be provided in case there is a chance that the user intervenes in a presentation and cancels the expectation.
    var resultOnUserCancel: ExpectedType?

    /// Helper type to hide other implementation details of ``Expectation``.
    /// This type only exposes a single method to complete the expectation.
    var resolver: Resolver!

    private init(resultOnUserCancel: ExpectedType?) {
        self.resultOnUserCancel = resultOnUserCancel
        buffer = Buffer()
        resolver = .init(handler: complete)
    }

    /// Initializes an expectation that could be interrupted by user interaction.
    ///
    /// An example would be a dismissable sheet.
    /// - Parameter resultOnUserCancel: The result that should be used to complete the expectation when it is cancelled by the user.
    /// - Returns: The expectation.
    public static func userCancellable(resultOnUserCancel: ExpectedType) -> Expectation<ExpectedType> {
        .init(resultOnUserCancel: resultOnUserCancel)
    }

    /// Initializes an expectation that is guaranteed not to be interrupted and cancelled by user interaction.
    ///
    /// An example would be a confirmation dialog.
    /// - Returns: The expectation.
    public static func guaranteedCompletion() -> Expectation<ExpectedType> {
        .init(resultOnUserCancel: nil)
    }

    /// Helper flag to determine if a continuation is currently stored.
    ///
    /// This is needed for runtime checks in ``Expecting/body``
    /// to inform about unfulfilled expectations (causing a `CheckedContinuation` to leak).
    var hasContinuation: Bool {
        get async {
            await buffer.hasContinuation
        }
    }

    // MARK: - isActive accessors

    /// Start the expectation by setting its `isActive` to `true`.
    public mutating func show() {
        isActive = true
    }

    /// Stops the expectation by setting its `isActive` to `false`.
    public mutating func hide() {
        isActive = false
    }

    // MARK: - Completion access

    /// Completes the expectation with a result.
    /// - Parameter result: The result of the expectation.
    public func complete(with result: ExpectedType) {
        Task {
            await buffer.complete(with: result)
        }
    }

    // MARK: - Result access

    /// The result of the expectation.
    ///
    /// Make sure to start the expectation before accessing this, or it will do nothing.
    public var result: ExpectedType {
        get async {
            // TODO: check if this has already been called and prevent it from happening again! it would override the old one.
            // Or cache the result and return it. delete the cache upon show()
            await withCheckedContinuation { continuation in
                Task {
                    await buffer.setContinuation(continuation)
                }
            }
        }
    }
}
