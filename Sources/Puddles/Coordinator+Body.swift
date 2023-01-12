import SwiftUI
import Combine

struct DeepLinkHandler: Equatable {
    let id: UUID

    private let buffer: Buffer = .init()
    var url: URL? {
        get { buffer.url }
        nonmutating set { buffer.url = newValue }
    }

    private class Buffer {
        var url: URL?
    }

    init(id: UUID, deepLinkUrl: URL? = nil) {
        self.id = id
        buffer.url = deepLinkUrl
    }

    static func == (lhs: DeepLinkHandler, rhs: DeepLinkHandler) -> Bool {
        lhs.id == rhs.id
    }
}

private struct DeepLinkEnvironmentKey: EnvironmentKey {
    static let defaultValue = DeepLinkHandler(id: .init())
}

extension EnvironmentValues {
    var deepLinkHandler: DeepLinkHandler {
        get { self[DeepLinkEnvironmentKey.self] }
        set { self[DeepLinkEnvironmentKey.self] = newValue }
    }
}

public struct DeepLinkRootModifier: ViewModifier {
    @State var handler: DeepLinkHandler = .init(id: .init())

    public func body(content: Content) -> some View {
        content
            .environment(\.deepLinkHandler, handler)
            .onOpenURL { url in
                handler = .init(id: .init(), deepLinkUrl: url)
            }
    }
}

public enum DeepLinkPropagation {
    case shouldContinue
    case hasFinished
}

struct Test: DynamicProperty {
    @Environment(\.deepLinkHandler) private var deepLinkHandler

    var handler: (_ url: URL) -> DeepLinkPropagation
    init(handler: @escaping (_: URL) -> DeepLinkPropagation) {
        self.handler = handler
    }

    func update() {
        guard let url = deepLinkHandler.url else { return }
        if handler(url) == .hasFinished {
            deepLinkHandler.url = nil
        }
    }
}

public extension View {
    func deepLinkRoot() -> some View {
        modifier(DeepLinkRootModifier())
    }
}

/// A helper view taking an `entryView` and configuring it for use as a ``Puddles/Coordinator``.
public struct CoordinatorBody<C: Coordinator>: View {
    @Environment(\.deepLinkHandler) private var deepLinkHandler

//    var test: Test
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

