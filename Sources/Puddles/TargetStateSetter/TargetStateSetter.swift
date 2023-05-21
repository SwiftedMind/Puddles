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
    @StateObject private var stateHolder: StateHolder

    public var wrappedValue: Wrapped {
        .init(
            identity: stateHolder.identity,
            valueForId: stateHolder.valueForId,
            onSend: stateHolder.send,
            removeValue: stateHolder.removeValue
        )
    }

    public init(
        initialTargetState value: Value? = nil,
        andId id: AnyHashable? = nil
    ) {
        _stateHolder = .init(wrappedValue: .init(value: value, id: id))
    }
}

public extension TargetStateSetter {

    @MainActor
    final class StateHolder: ObservableObject {
        private let emptyId = AnyHashable(UUID())
        private var value: [AnyHashable: Value] = [:]
        @Published private(set) var identity: UUID = .init()

        init(value: Value? = nil, id: AnyHashable?) {
            self.value[id ?? emptyId] = value
        }

        func valueForId(_ id: AnyHashable?) -> Value? {
            value[id ?? emptyId]
        }

        func send(_ value: Value, id: AnyHashable?) {
            self.value[id ?? emptyId] = value
            identity = .init()
        }

        func removeValue(id: AnyHashable?) {
            self.value.removeValue(forKey: id ?? emptyId)
        }
    }

    struct Wrapped: Equatable {
        var identity: UUID
        var valueForId: (_ id: AnyHashable?) -> Value?
        var onSend: @MainActor (_ value: Value, _ id: AnyHashable?) -> Void
        var removeValue: (_ id: AnyHashable?) -> Void

        /// Sends a target state.
        /// - Parameter value: The target state to send.
        @MainActor
        public func apply(_ value: Value, id: AnyHashable? = nil) {
            onSend(value, id)
        }

        public static func == (lhs: TargetStateSetter<Value>.Wrapped, rhs: TargetStateSetter<Value>.Wrapped) -> Bool {
            lhs.identity == rhs.identity
        }
    }
}
