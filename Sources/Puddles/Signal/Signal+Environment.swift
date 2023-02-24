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

@available(iOS 16, *)
public extension Navigator {
    func updatingStateConfiguration(on signal: Signal<StateConfiguration>.Wrapped) -> some View {
        environment(\.signal, .init(id: signal.id, value: signal.value, onSignalHandled: signal.removeValue))
    }
}
