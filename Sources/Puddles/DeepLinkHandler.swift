import SwiftUI

/*

 Experimental!

 */

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

public extension View {
    func deepLinkRoot() -> some View {
        modifier(DeepLinkRootModifier())
    }
}
