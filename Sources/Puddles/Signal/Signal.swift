import Combine
import SwiftUI

/// A property wrapper that lets you send one-time TargetStateSetters down the view hierarchy,
/// which is particularly useful for deep linking and state restoration without exposing all internal states of the child views.
///
/// You can think of this as the opposite of closures, which are TargetStateSetters going from child view to a parent (like a button's action).
///
/// To make a ``Puddles/Navigator`` receive TargetStateSetters,
/// use the `updatingTargetStateSetter(on:)` view modifier and provide a TargetStateSetter whose value is the target navigator's
/// ``Puddles/Navigator/TargetStateSetter``.
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

    public init(initialTargetStateSetter value: Value? = nil) {
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

        /// Sends a TargetStateSetter.
        /// - Parameter value: The value of the TargetStateSetter.
        @MainActor
        public func `set`(_ value: Value) {
            onSend(value)
        }

        public static func == (lhs: TargetStateSetter<Value>.Wrapped, rhs: TargetStateSetter<Value>.Wrapped) -> Bool {
            lhs.id == rhs.id
        }
    }
}
