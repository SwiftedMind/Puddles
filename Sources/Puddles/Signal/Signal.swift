import Combine
import SwiftUI

@propertyWrapper
public struct Signal<Value>: DynamicProperty {
    @StateObject private var stateHolder = StateHolder()

    public var wrappedValue: Wrapped {
        .init(id: stateHolder.id, value: stateHolder.value) { content in
            stateHolder.send(content)
        } removeValue: {
            stateHolder.removeValue()
        }
    }

    public init(initialSignal value: Value? = nil) {
        _stateHolder = .init(wrappedValue: .init(value: value))
    }

}

public extension Signal {

    @MainActor
    final class StateHolder: ObservableObject {
        private(set) var value: Value?
        private(set) var id: UUID = .init()

        init(value: Value? = nil) {
            self.value = value
        }

        func send(_ value: Value) {
            self.value = value
            id = .init()
            objectWillChange.send()
        }

        func removeValue() {
            value = nil
        }
    }

    struct Wrapped: Equatable {
        var id: UUID
        var value: Value?
        var onSend: (_ value: Value) -> Void
        var removeValue: () -> Void

        public func send(_ value: Value) {
            onSend(value)
        }

        public static func == (lhs: Signal<Value>.Wrapped, rhs: Signal<Value>.Wrapped) -> Bool {
            lhs.id == rhs.id
        }
    }
}
