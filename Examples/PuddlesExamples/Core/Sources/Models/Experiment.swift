import SwiftUI

public struct Experiment: Identifiable, Equatable, Sendable {
    public var id: UUID
    public var title: String
    public var description: String

    public init(id: UUID = UUID(), title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}
