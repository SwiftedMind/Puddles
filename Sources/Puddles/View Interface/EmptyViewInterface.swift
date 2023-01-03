import SwiftUI
import Combine

/// An empty view interface.
@MainActor public final class EmptyViewInterface: ViewInterface {
    public init() {}
    public var actionPublisher: PassthroughSubject<NoAction, Never> = .init()
}
