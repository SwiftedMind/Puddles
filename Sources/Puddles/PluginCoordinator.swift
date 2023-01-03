import SwiftUI

// TODO: Implement this way to shortcut commonly used coordinators (like a settings sheet)

/* Idea:

 Coordinator().installPlugin(\.keyPathToSomeIdentifier) { isActive in
   Sheet(isActive: isActive) {
     SettingsCoordinator()
   }
 }

 // Inside other Coordinators:

 // Stores state
 @Plugin(\.keyPathToSomeIdentifier) var settings

 settings.show()
 settings.hide()
 settings.setVisible(true|false

 Maybe optionally combine with expectations

 */

public struct PluginCoordinator<C: Coordinator>: View {

    public var body: some View {
        Text("")
    }

}

public struct CoordinatorPluginModifier<C: Coordinator>: ViewModifier {

    @Binding var isActive: Bool
    let coordinator: C

    init(isActive: Binding<Bool>, coordinator: C) {
        self.coordinator = coordinator
        self._isActive = isActive
    }

    public func body(content: Content) -> some View {
        content
    }
}

public extension View {
    func coordinatorPlugin(_ coordinator: some Coordinator, isActive: Binding<Bool>) -> some View {
        modifier(CoordinatorPluginModifier(isActive: isActive, coordinator: coordinator))
    }
}
