import SwiftUI
import Combine

/// A type that handles state and data management of a child.
///
/// - Important: Do not implement the `body` property yourself. Use ``Puddles/Provider/entryView-swift.property`` instead!
public protocol Provider<TargetState>: View {

    /// The type of the ``Puddles/Provider/entryView-swift.property`` for the ``Puddles/Provider``.
    ///
    /// This can be inferred by providing an `entryView`.
    associatedtype EntryView: View

    /// The type of the target state.
    ///
    /// This can be inferred by defining the ``Puddles/Provider/applyTargetState(_:)`` method in a ``Puddles/Provider``.
    associatedtype TargetState

    /// The final `View` type for the ``Puddles/Provider``,
    /// which is determined by the ``Puddles/Provider/modify(provider:)-9enjl method.
    associatedtype FinalBody: View

    /// A representation of the fully configured provider content.
    ///
    /// This is an internal helper view type whose ``Puddles/ProviderBody/body`` contains all the needed modifiers to setup the ``Puddles/Provider``.
    typealias ProviderContent = ProviderBody<Self>

    /// An identifier that can be used to name the `Provider`.
    ///
    /// This might be helpful while debugging.
    @MainActor static var debugIdentifier: String { get }

    /// The entry point for this provider, which should be its root `View`.
    ///
    /// It is safe (and usually expected) to provide modifications that define the context of the root, like setting a navigation title or adding a toolbar.
    @ViewBuilder @MainActor var entryView: EntryView { get }

    /// A method that modifies the content of the ``Puddles/Provider``, whose view representation is passed as an argument.
    /// The result of this method is used as the Provider's `body` property.
    ///
    /// A default implementation is provided that simply returns the provided ``Puddles/Provider``.
    ///
    /// A typical application is to wrap the provider in a `NavigationView` or
    ///  `NavigationStack`:
    ///
    /// ```swift
    /// func modify(provider: ProviderContent) -> some View {
    ///     NavigationStack {
    ///         provider
    ///     }
    ///     .environmentObject(myService)
    /// }
    /// ```
    ///
    /// For simple use cases, this is fine. If you build more complex components, consider using a ``Puddles/Navigator`` instead and put the `NavigationStack` there.
    ///
    /// - Tip: Due to a Swift Compiler bug, autocomplete will insert the wrong method signature for this method. It will use `FinalBody` as return type, instead of the correct `some View` type. Be aware that you have to manually correct this, or otherwise the code will not compile.
    ///
    /// - Parameter provider: A representation of the fully configured provider content.
    /// - Returns: A view that modifies the provided provider.
    @ViewBuilder @MainActor func modify(provider: ProviderContent) -> FinalBody

    /// Sets the state of the provider according to the provided target state.
    ///
    /// - Parameter state: The target state to apply.
    @MainActor func applyTargetState(_ state: TargetState)

    /// A method that is called when the provider has first appeared.
    ///
    /// The parent task is bound to the Provider's lifetime and is cancelled once it ends.
    /// Keep in mind, that it is up to the implementation to check for cancellations!
    ///
    /// - Important: This method is intentionally *not* called `onAppear()`.
    /// It does not behave like the `.onAppear(perform:)` view modifier,
    /// which can be called multiple times during the lifetime of the view.
    /// Instead, `start()` is only called exactly once, when the lifetime of the ``Puddles/Provider`` starts.
    @MainActor func start() async

    /// A method that is called after the provider has disappeared for the last and final time.
    ///
    /// More specifically, this method is called when SwiftUI deinitializes the `Provider`'s data objects (think `@StateObject`), which,
    /// may occur some time *after* the final disappearance (due to optimizations by SwiftUI). It is, however, guaranteed to be called.
    /// Immediately before it is called, the `Task` that runs the ``Puddles/Provider/start()-9xt0v`` method is cancelled.
    ///
    ///- Important: This method is intentionally *not* called `onDisappear()`.
    /// It does not behave like the `.onDisappear(perform:)` view modifier,
    /// which can be called multiple times during the lifetime of the view.
    /// Instead, `stop()` is only called exactly once, when the lifetime of the ``Puddles/Provider`` ends.
    @MainActor func stop()
}

public extension Provider {

    @MainActor static var debugIdentifier: String {
        "\(type(of: Self.self))"
    }

    // The final body for the provider, consisting of the modified `ProviderBody` helper
    @MainActor var body: some View {
        modify(
            provider: ProviderBody(
                entryView: entryView,
                applyTargetStateHandler: applyTargetState,
                firstAppearHandler: {
                    await start()
                },
                finalDisappearHandler: {
                    stop()
                }
            )
        )
    }

    // Default implementation for the provider content modification.
    @MainActor func modify(provider: ProviderContent) -> some View {
        provider
    }

    @MainActor func start() async {}
    @MainActor func stop() {}
}
