import Combine
import SwiftUI

/// A property wrapper that lets you send one-time signals down the view hierarchy,
/// which is particularly useful for deep linking and state restoration without exposing all internal states of the child views.
///
/// You can think of this as the opposite of closures, which are signals going from child view to a parent (like a button's action).
///
/// To make a ``Puddles/Navigator`` receive signals,
/// use the `updatingStateConfiguration(on:)` view modifier and provide a signal whose value is the target navigator's
/// ``Puddles/Navigator/StateConfiguration``.
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
        var onSend: @MainActor (_ value: Value) -> Void
        var removeValue: () -> Void

        /// Sends a signal.
        /// - Parameter value: The value of the signal.
        @MainActor
        public func send(_ value: Value) {
            onSend(value)
        }

        public static func == (lhs: Signal<Value>.Wrapped, rhs: Signal<Value>.Wrapped) -> Bool {
            lhs.id == rhs.id
        }
    }
}
