public struct Interface<Action> {
    private let actionHandler: @Sendable (_ action: Action) -> Void

    public static func actionHandler(_ handler: @escaping @Sendable (_ action: Action) -> Void) -> Self {
        .init(actionHandler: handler)
    }

    public func sendAction(_ action: Action) {
        actionHandler(action)
    }

    public func binding<Value>(
        _ value: @autoclosure @escaping () -> Value,
        to action: @escaping (_ newValue: Value) -> Action
    ) -> Binding<Value> {
        .init(get: value) { newValue in
            actionHandler(action(newValue))
        }
    }
}
