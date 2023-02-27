import SwiftUI
import Combine

/// A type that coordinates the dependency and data management of a `View`.
public protocol Coordinator: View {

    /// The type of the ``Puddles/Coordinator/entryView-swift.property`` for the ``Puddles/Coordinator``.
    ///
    /// This can be inferred by providing an `entryView`.
    associatedtype EntryView: View

    /// The final `View` type for the ``Puddles/Coordinator``,
    /// which is determined by the ``Puddles/Coordinator/modify(coordinator:)-19rqn`` method.
    associatedtype FinalBody: View

    /// A representation of the fully configured coordinator content.
    ///
    /// This is an internal helper view type whose ``Puddles/CoordinatorBody/body`` contains all the needed modifiers to setup the ``Puddles/Coordinator``.
    typealias CoordinatorContent = CoordinatorBody<Self>

    /// An identifier that can be used to name the `Coordinator`.
    ///
    /// This might be helpful while debugging.
    @MainActor static var debugIdentifier: String { get }

    /// The entry point for this coordinator, which should be its root `View`.
    ///
    /// It is safe (and usually expected) to provide modifications that define the context of the root, like setting a navigation title or adding a toolbar.
    @ViewBuilder @MainActor var entryView: EntryView { get }

    /// A method that modifies the content of the ``Puddles/Coordinator``, whose view representation is passed as an argument.
    /// The result of this method is used as the Coordinator's `body` property.
    ///
    /// A default implementation is provided that simply returns the provided ``Puddles/Coordinator``.
    ///
    /// A typical application is to wrap the coordinator in a `NavigationView` or
    ///  `NavigationStack`:
    ///
    /// ```swift
    /// func modify(coordinator: CoordinatorContent) -> some View {
    ///     NavigationView {
    ///         coordinator
    ///     }
    ///     .environmentObject(myService)
    /// }
    /// ```
    ///
    /// When you need to implement a `NavigationSplitView` or need iPad support,
    /// you need to wrap your root `Coordinator` in a view that provides the `NavigationSplitView`, as `Coordinator` currently does not support this in a convenient way.
    ///
    /// - Tip: Due to a Swift Compiler bug, autocomplete will insert the wrong method signature for this method. It will use `FinalBody` as return type, instead of the correct `some View` type. Be aware that you have to manually correct this, or otherwise the code will not compile.
    ///
    /// - Parameter coordinator: A representation of the fully configured coordinator content.
    /// - Returns: A view that modifies the provided coordinator.
    @ViewBuilder @MainActor func modify(coordinator: CoordinatorContent) -> FinalBody

    /// A method that is called when the coordinator has first appeared.
    ///
    /// The parent task is bound to the Coordinator's lifetime and is cancelled once it ends.
    /// Keep in mind, that it is up to the implementation to check for cancellations!
    ///
    /// - Important: This method is intentionally *not* called `onAppear()`.
    /// It does not behave like the `.onAppear(perform:)` view modifier,
    /// which can be called multiple times during the lifetime of the view.
    /// Instead, `start()` is only called exactly once, when the lifetime of the ``Puddles/Coordinator`` starts.
    @MainActor func start() async

    /// A method that is called after the coordinator has disappeared for the last and final time.
    ///
    /// More specifically, this method is called when SwiftUI deinitializes the `Coordinator`'s data objects (think `@StateObject`), which,
    /// may occur some time *after* the final disappearance (due to optimizations by SwiftUI). It is, however, guaranteed to be called.
    /// Immediately before it is called, the `Task` that runs the ``Puddles/Coordinator/start()-7oqfy`` method is cancelled.
    ///
    ///- Important: This method is intentionally *not* called `onDisappear()`.
    /// It does not behave like the `.onDisappear(perform:)` view modifier,
    /// which can be called multiple times during the lifetime of the view.
    /// Instead, `stop()` is only called exactly once, when the lifetime of the ``Puddles/Coordinator`` ends.
    @MainActor func stop()
}

public extension Coordinator {

    @MainActor static var debugIdentifier: String {
        "\(type(of: Self.self))"
    }

    // The final body for the coordinator, consisting of the modified `CoordinatorBody` helper
    @MainActor var body: some View {
        modify(
            coordinator: CoordinatorBody(
                entryView: entryView,
                firstAppearHandler: {
                    await start()
                },
                finalDisappearHandler: {
                    stop()
                }
            )
        )
    }

    // Default implementation for the coordinator content modification.
    @MainActor func modify(coordinator: CoordinatorContent) -> some View {
        coordinator
    }

    @MainActor func start() async {}
    @MainActor func stop() {}
}
