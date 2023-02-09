public struct Interface<Action> {
    private let actionHandler: (_ action: Action) -> Void

    public static func handled(by block: @escaping (_ action: Action) -> Void) -> Self {
        .init(actionHandler: block)
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
