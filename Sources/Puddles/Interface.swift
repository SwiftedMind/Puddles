import SwiftUI

/// A type that can send actions to a handler, which is usually a ``Puddles/Coordinator`` or ``Puddles/Navigator``.
public struct Interface<Action> {
    private let actionHandler: @MainActor (_ action: Action) -> Void

    /// Initializes an interface that sends actions to the given closure.
    /// - Parameter block: The closure that will handle incoming actions.
    /// - Returns: An instance of the interface.
    public static func handled(by block: @escaping @MainActor (_ action: Action) -> Void) -> Self {
        .init(actionHandler: block)
    }

    /// Initializes an interface that sends actions to another interface.
    /// - Parameter otherInterface: The interface that will handle incoming actions.
    /// - Returns: An instance of the interface.
    public static func handled(by otherInterface: Interface<Action>) -> Self {
        .init(actionHandler: otherInterface.actionHandler)
    }

    /// Initializes an interface with an empty closure.
    public static var unhandled: Self {
        .init(actionHandler: {_ in})
    }

    /// Sends an action to the interface.
    /// - Parameter action: The action to send.
    @MainActor
    public func sendAction(_ action: Action) {
        actionHandler(action)
    }

    /// Creates a binding to a value, with a setter that sends an action.
    ///
    /// Use this instead of "classic" @State bindings to adhere to the concept of unidirectional communication.
    ///
    /// - Parameters:
    ///   - value: The getter for the binding.
    ///   - action: The action to send when setting a new value on the binding.
    /// - Returns: A binding to the specific value.
    @MainActor
    public func binding<Value>(
        _ value: @autoclosure @escaping () -> Value,
        to action: @escaping (_ newValue: Value) -> Action
    ) -> Binding<Value> {
        .init(get: value) { newValue in
            actionHandler(action(newValue))
        }
    }
}
