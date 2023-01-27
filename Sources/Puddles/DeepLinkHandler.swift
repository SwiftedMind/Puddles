import SwiftUI

class DeepLinkStorage: ObservableObject, Equatable {
    static var shared: DeepLinkStorage = .init(id: .init())
    @Published var id: UUID = .init()
    @Published var url: URL?

    init(id: UUID, deepLinkUrl: URL? = nil) {
        self.id = id
        self.url = deepLinkUrl
    }

    static func == (lhs: DeepLinkStorage, rhs: DeepLinkStorage) -> Bool {
        lhs.id == rhs.id
    }
}
