import SwiftUI

struct TargetStateSetterWrapper: Equatable {
    var id: UUID?
    var value: Any?
    var onTargetStateSet: @MainActor () -> Void

    public static func == (lhs: TargetStateSetterWrapper, rhs: TargetStateSetterWrapper) -> Bool {
        lhs.id == rhs.id
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

// MARK: - Navigator Extension

public extension Navigator {

    /// Configures the navigator to receive TargetStateSetters that send target states. The received TargetStateSetters are automatically applied by calling ``Puddles/Navigator/applyTargetStateSetter(_:)``.
    ///
    /// - Parameter TargetStateSetter: The TargetStateSetter that sends the navigator's `TargetStateSetter`.
    /// - Returns: A view with a configured TargetStateSetter reception.
    func targetStateSetter(_ targetStateSetter: TargetStateSetter<TargetState>.Wrapped) -> some View {
        environment(\.targetStateSetter, .init(id: targetStateSetter.id, value: targetStateSetter.value, onTargetStateSet: targetStateSetter.removeValue))
    }
}

// MARK: - Provider Extension

public extension Provider {

    /// Configures the provider to receive TargetStateSetters that send target states. The received TargetStateSetters are automatically applied by calling ``Puddles/Provider/applyTargetStateSetter(_:)``.
    ///
    /// - Parameter TargetStateSetter: The TargetStateSetter that sends the provider's `TargetStateSetter`.
    /// - Returns: A view with a configured TargetStateSetter reception.
    func targetStateSetter(_ targetStateSetter: TargetStateSetter<TargetState>.Wrapped) -> some View {
        environment(\.targetStateSetter, .init(id: targetStateSetter.id, value: targetStateSetter.value, onTargetStateSet: targetStateSetter.removeValue))
    }
}
