import SwiftUI
import Combine

@MainActor
public struct InterfacePublisherObserver<Action, I: Interface<Action>, P: Publisher<Action, Never>>: InterfaceObservation {
    var interface: I
    var publisher: P
    var actionHandler: @MainActor (_ action: Action) -> Void

    public init(
        _ interface: I,
        publisher: (_ publisher: PassthroughSubject<Action, Never>) -> P,
        actionHandler: @MainActor @escaping (_ action: Action) -> Void
    ) {
        self.interface = interface
        self.publisher = publisher(interface.actionPublisher)
        self.actionHandler = actionHandler
    }
}

public extension InterfacePublisherObserver {

    var body: some View {
        Color.clear
            .onReceive(publisher) { action in
                actionHandler(action)
            }
    }
}
