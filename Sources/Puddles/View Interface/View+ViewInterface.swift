import SwiftUI

public extension View {
    /// Adds a subscription to the interface and calls the given handler whenever an action is sent.
    /// - Parameters:
    ///   - interface: The interface to connect to.
    ///   - handler: The handler that is invoked on each sent action.
    /// - Returns: A view that's modified to have a subscription to the view interface.
    @MainActor func connectingInterface<Action, Interface: ViewInterface<Action>>(_ interface: Interface, to handler: @escaping (_ action: Action) async -> Void) -> some View {
        onReceive(interface.actionPublisher) { action in
            Task {
                await handler(action)
            }
        }
    }
}
