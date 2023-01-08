import SwiftUI

public struct InterfaceObserver<Action, I: Interface<Action>>: InterfaceObservation {

    var interface: I
    var actionHandler: @MainActor (_ action: Action) -> Void

    public init(
        _ interface: I,
        actionHandler: @MainActor @escaping (_ action: Action) -> Void
    ) {
        self.interface = interface
        self.actionHandler = actionHandler
    }
}

public extension InterfaceObserver {

    @MainActor
    var body: some View {
        Color.clear
            .onReceive(interface.actionPublisher) { action in
                actionHandler(action)
            }
    }
}

