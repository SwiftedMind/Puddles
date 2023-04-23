import Combine
import SwiftUI

/// A property wrapper that lets you send one-time signals down the view hierarchy,
/// which is particularly useful for deep linking and state restoration without exposing all internal states of the child views.
///
/// You can think of this as the opposite of closures, which act like signals going from child view to a parent (like a button's action).
///
/// To make a ``Puddles/Navigator`` receive TargetStateSetters,
/// use the `.targetStateSetter(_:)` view modifier on it and provide a TargetStateSetter whose value is the target navigator's
/// ``Puddles/Navigator/TargetState``.
@propertyWrapper
public struct TargetStateSetter<Value>: DynamicProperty {
    @StateObject private var stateHolder = StateHolder()

    public var wrappedValue: Wrapped {
        .init(id: stateHolder.id, value: stateHolder.value) { content in
            stateHolder.send(content)
        } removeValue: {
            stateHolder.removeValue()
        }
    }

    public init(initialTargetState value: Value? = nil) {
        _stateHolder = .init(wrappedValue: .init(value: value))
    }
}

public extension TargetStateSetter {

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

        /// Sends a target state.
        /// - Parameter value: The target state to send.
        @MainActor
        public func `set`(_ value: Value) {
            onSend(value)
        }

        public static func == (lhs: TargetStateSetter<Value>.Wrapped, rhs: TargetStateSetter<Value>.Wrapped) -> Bool {
            lhs.id == rhs.id
        }
    }
}
