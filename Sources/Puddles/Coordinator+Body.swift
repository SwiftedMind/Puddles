import SwiftUI
import Combine

/// A helper view taking an `entryView` and configuring it for use as a ``Puddles/Coordinator``.
public struct CoordinatorBody<C: Coordinator>: View {
    @Environment(\.deepLinkHandler) private var deepLinkHandler

    private var onDeepLink: (_ url: URL) -> DeepLinkPropagation

    /// The root view of the `Coordinator` as provided in ``Puddles/Coordinator/entryView-swift.property``.
    private let entryView: C.EntryView

    /// The navigation content of the `Coordinator` as provided in ``Puddles/Coordinator/navigation()``.
    private let navigation: C.NavigationContent

    /// The interfaces of the `Coordinator` as provided in ``Puddles/Coordinator/interfaces().
    private let interfaces: C.Interfaces

    /// A closure reporting back first appearance of the view.
    private let firstAppearHandler: () async -> Void

    /// A closure reporting back the last disappearance of the view.
    private let finalDisappearHandler: () -> Void

    /// A helper view taking an `entryView` and configuring it for use as a ``Puddles/Coordinator``.
    init(
        entryView: C.EntryView,
        navigation: C.NavigationContent,
        interfaces: C.Interfaces,
        firstAppearHandler: @escaping () async -> Void,
        finalDisappearHandler: @escaping () -> Void,
        onDeepLink: @escaping (_: URL) -> DeepLinkPropagation
    ) {
        self.entryView = entryView
        self.navigation = navigation
        self.interfaces = interfaces
        self.firstAppearHandler = firstAppearHandler
        self.finalDisappearHandler = finalDisappearHandler
        self.onDeepLink = onDeepLink
    }

    public var body: some View {
        ZStack { // To prevent the case of entryView being a Tuple. Then all the modifiers would be applied for every view in the tuple!
            entryView
        }
        .background(navigation)
        .background(interfaces)
        .background {
            ViewLifetimeHelper {
                await firstAppearHandler()
            } onDeinit: {
                finalDisappearHandler()
            }
        }
        .onAppear {
            if let url = deepLinkHandler.url {
                if onDeepLink(url) == .hasFinished {
                    deepLinkHandler.url = nil
                }
            }
        }
        .onChange(of: deepLinkHandler) { deepLinkHandler in
            if let url = deepLinkHandler.url {
                if onDeepLink(url) == .hasFinished {
                    deepLinkHandler.url = nil
                }
            }
        }
    }
}

