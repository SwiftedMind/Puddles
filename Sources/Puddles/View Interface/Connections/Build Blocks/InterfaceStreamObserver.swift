import SwiftUI
import Combine

public struct InterfaceStreamObserver<Action, I: Interface<Action>>: InterfaceDescription {
    var interface: I
    var actionHandler: @Sendable (_ stream: AsyncStream<Action>) async -> Void

    public init(
        _ interface: I,
        actionHandler: @Sendable @escaping (_ stream: AsyncStream<Action>) async -> Void
    ) {
        self.interface = interface
        self.actionHandler = actionHandler
    }
}

public extension InterfaceStreamObserver {

    @MainActor
    var body: some View {
        Color.clear
            .task {
                // TODO: Keep an eye on this. It cancels and re-starts during navigation pushes.
                // Should be fine in terms of use cases (when the view is down the navigation stack, no action should ever be sent anyways)
                // Replace with ViewLifetimeHelper if needed
                await actionHandler(interface.actionStream)
            }
    }
}
