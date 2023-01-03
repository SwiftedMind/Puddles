import SwiftUI

/// A helper view taking an `entryView` and configuring it for use as a ``Puddles/Coordinator``.
public struct CoordinatorBody<C: Coordinator>: View {

    /// The root view of the `Coordinator` as provided in ``Puddles/Coordinator/entryView-swift.property``.
    private let entryView: C.EntryView

    /// The navigation content of the `Coordinator` as provided in ``Puddles/Coordinator/navigation()``.
    private let navigation: C.NavigationContent

    /// The interface of the `Coordinator` as provided in ``Puddles/Coordinator/interface-swift.property-5oyxi``.
    private let interface: C.Interface

    /// A closure reporting back the actions sent from the `interface`.
    private let actionHandler: (_ action: C.Interface.Action) -> Void

    /// A closure reporting back first appearance of the view.
    private let firstAppearHandler: () async -> Void

    /// A closure reporting back the last disappearance of the view.
    private let finalDisappearHandler: () -> Void

    /// A helper view taking an `entryView` and configuring it for use as a ``Puddles/Coordinator``.
    init(
        entryView: C.EntryView,
        navigation: C.NavigationContent,
        interface: C.Interface,
        actionHandler: @escaping (_: C.Interface.Action) -> Void,
        firstAppearHandler: @escaping () async -> Void,
        finalDisappearHandler: @escaping () -> Void
    ) {
        self.entryView = entryView
        self.navigation = navigation
        self.interface = interface
        self.actionHandler = actionHandler
        self.firstAppearHandler = firstAppearHandler
        self.finalDisappearHandler = finalDisappearHandler
    }

    public var body: some View {
        ZStack { // To prevent the case of entryView being a Tuple. Then all the modifiers would be applied for every view in the tuple!
            entryView
        }
        .background(navigation)
        .onReceive(interface.actionPublisher) { action in
            actionHandler(action)
        }
        .background {
            ViewLifetimeHelper {
                await firstAppearHandler()
            } onDeinit: {
                finalDisappearHandler()
            }
        }
    }
}

