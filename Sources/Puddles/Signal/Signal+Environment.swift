import SwiftUI

struct SignalWrapper: Equatable {
    var id: UUID?
    var value: Any?
    var onSignalHandled: () -> Void

    public static func == (lhs: SignalWrapper, rhs: SignalWrapper) -> Bool {
        lhs.id == rhs.id
    }
}

private struct SignalKey: EnvironmentKey {
    static let defaultValue: SignalWrapper? = nil
}

extension EnvironmentValues {
    var signal: SignalWrapper? {
        get { self[SignalKey.self] }
        set { self[SignalKey.self] = newValue }
    }
}

public extension Navigator {

    /// Configures the navigator to receive signals that send state configurations. The received signals are automatically applied by calling ``Puddles/Navigator/applyStateConfiguration(_:)``.
    ///
    /// - Parameter signal: The signal that sends the navigator's `StateConfiguration`.
    /// - Returns: A view with a configured signal reception.
    func updatingStateConfiguration(on signal: Signal<StateConfiguration>.Wrapped) -> some View {
        environment(\.signal, .init(id: signal.id, value: signal.value, onSignalHandled: signal.removeValue))
    }
}
