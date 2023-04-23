import SwiftUI

/// A type that can send actions to a handler, which is usually a ``Puddles/Provider`` or ``Puddles/Navigator`` but can be anything.
public struct Interface<Action> {
    private let actionHandler: @MainActor (_ action: Action) -> Void

    /// Initializes an interface that sends actions to the given closure.
    /// - Parameter block: The closure that will handle incoming actions.
    /// - Returns: An instance of the interface.
    public static func consume(_ block: @escaping @MainActor (_ action: Action) -> Void) -> Self {
        .init(actionHandler: block)
    }

    /// Initializes an interface that forwards all actions to another interface.
    ///
    /// This is a convenient method that is equivalent to simply passing the other interface as a property. Use this, to clarify the nature of the interface forwarding.
    ///
    /// This method does not create an additional indirection since the other interface's closure will be directly accessed and stored as the action handler.
    /// - Parameter otherInterface: The interface that will handle incoming actions.
    /// - Returns: An instance of the interface.
    public static func forward(to otherInterface: Interface<Action>) -> Self {
        .init(actionHandler: otherInterface.actionHandler)
    }

    /// Initializes an interface with an empty closure.
    public static var ignore: Self {
        .init(actionHandler: {_ in})
    }

    /// Sends an action to the interface.
    /// - Parameter action: The action to send.
    @MainActor
    public func fire(_ action: Action) {
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
