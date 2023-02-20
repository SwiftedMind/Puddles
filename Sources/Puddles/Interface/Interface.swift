import SwiftUI

public struct Interface<Action> {
    private let actionHandler: @MainActor (_ action: Action) -> Void

    public static func handled(by block: @escaping @MainActor (_ action: Action) -> Void) -> Self {
        .init(actionHandler: block)
    }

    public static var unhandled: Self {
        .init(actionHandler: {_ in})
    }

    @MainActor
    public func sendAction(_ action: Action) {
        actionHandler(action)
    }

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
