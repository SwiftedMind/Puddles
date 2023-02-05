import SwiftUI

private(set) var stateConfigurations: [UUID: Any] = [:]

private struct StateConfigurationKey: EnvironmentKey {
    static let defaultValue: UUID = .init()
}

extension EnvironmentValues {
    var stateConfigurationId: UUID {
        get { self[StateConfigurationKey.self] }
        set { self[StateConfigurationKey.self] = newValue }
    }
}

@available(iOS 16, macOS 13.0, *)
struct StateConfigurationWrapper<Navigator: StackNavigator>: ViewModifier {
    @State var id = UUID()
    var configuration: Navigator.StateConfiguration?

    func body(content: Content) -> some View {
        content
            .environment(\.stateConfigurationId, id)
            .onAppear {
                stateConfigurations[id] = configuration
            }
            .onDisappear {
                stateConfigurations.removeValue(forKey: id)
            }
    }
}

@available(iOS 16, macOS 13.0, *)
public extension StackNavigator {
    func initialStateConfiguration(_ configuration: StateConfiguration?) -> some View {
        modifier(StateConfigurationWrapper<Self>(configuration: configuration))
    }
}
