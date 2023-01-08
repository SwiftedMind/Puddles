import SwiftUI
import Combine

@MainActor
public struct PublisherObserver<Value, P: Publisher<Value, Never>>: InterfaceObservation {
    var publisher: P
    var subscription: @MainActor (_ value: Value) -> Void

    public init(
        publisher: @autoclosure () -> P,
        subscription: @MainActor @escaping (_ value: Value) -> Void
    ) {
        self.publisher = publisher()
        self.subscription = subscription
    }
}

public extension PublisherObserver {

    var body: some View {
        Color.clear
            .onReceive(publisher) { value in
                subscription(value)
            }
    }
}
