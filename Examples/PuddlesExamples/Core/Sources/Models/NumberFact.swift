import SwiftUI

public struct NumberFact: Identifiable, Equatable {
    public var id: Int { number }
    public var number: Int
    public var content: String?

    public init(number: Int, content: String? = nil) {
        self.number = number
        self.content = content
    }
}
