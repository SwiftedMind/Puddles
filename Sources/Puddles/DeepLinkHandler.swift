import SwiftUI

class DeepLinkStorage: ObservableObject {
    static var shared: DeepLinkStorage = .init()
    @Published var deepLink: DeepLink?

    init(deepLink: DeepLink? = nil) {
        self.deepLink = deepLink
    }
}

extension DeepLinkStorage {
    struct DeepLink: Equatable {
        let id: UUID = .init()
        var url: URL
    }
}
