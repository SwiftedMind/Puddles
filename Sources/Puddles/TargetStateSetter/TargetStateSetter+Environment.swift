import SwiftUI

struct TargetStateSetterWrapper: Equatable {
    var identity: UUID
    var id: AnyHashable?
    var value: Any?
    var onTargetStateSet: @MainActor (_ id: AnyHashable?) -> Void

    public static func == (lhs: TargetStateSetterWrapper, rhs: TargetStateSetterWrapper) -> Bool {
        lhs.identity == rhs.identity
    }
}

private struct TargetStateSetterKey: EnvironmentKey {
    static let defaultValue: TargetStateSetterWrapper? = nil
}

extension EnvironmentValues {
    var targetStateSetter: TargetStateSetterWrapper? {
        get { self[TargetStateSetterKey.self] }
        set { self[TargetStateSetterKey.self] = newValue }
    }
}

// MARK: - Provider Extension

public extension Provider {

    /// Configures the provider to receive target states.
    ///
    /// - Parameter targetStateSetter: The TargetStateSetter that sends the provider's target states.
    /// - Parameter id: An identifier to identify the target state's owner.
    /// - Returns: A view with a configured TargetStateSetter reception.
    func applyTargetStates(
        with targetStateSetter: TargetStateSetter<TargetState>.Wrapped,
        id: AnyHashable? = nil
    ) -> some View {
        return environment(
            \.targetStateSetter,
                .init(
                    identity: targetStateSetter.identity,
                    id: id,
                    value: targetStateSetter.valueForId(id),
                    onTargetStateSet: targetStateSetter.removeValue
                )
        )
    }
}
