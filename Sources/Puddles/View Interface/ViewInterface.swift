// Copyright 2022 apploft GmbH. All rights reserved.

import Combine
import SwiftUI

/// An empty type representing the lack of actions in a view interface.
public struct NoAction {
    private init() {}
}

/// An `ObservableObject` that provides the means of sending signals to a `Coordinator`.
public protocol ViewInterface<Action>: ObservableObject {

    /// The type of the signals that are sent to the `Coordinator` via the `actionPublisher`.
    associatedtype Action = NoAction

    // TODO: Replace with AsyncChannel from AsyncAlgorithms.
    /// The publisher emitting signals that are subscribed to by a `Coordinator`.
    @MainActor var actionPublisher: PassthroughSubject<Action, Never> { get }

    /// A convenience method that emits the provided signal.
    ///
    /// You do not have to provide an implementation for this method.
    /// - Parameter action: The signal to send.
    @MainActor func sendAction(_ action: Action)

}

public extension ViewInterface {
    @MainActor func sendAction(_ action: Action) {
        actionPublisher.send(action)
    }
}

public extension Binding {
    @MainActor func sendingTo<Action>(
        _ interface: some ViewInterface<Action>,
        action: Action
    ) -> Binding<Value> {
        .init {
            wrappedValue
        } set: { newValue in
            interface.sendAction(action)
        }
    }
}
