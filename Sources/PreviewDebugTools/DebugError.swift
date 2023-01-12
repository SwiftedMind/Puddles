import Foundation

public struct DebugError: Error {
    public init() {}
}

public extension Error where Self == DebugError {
    static var debug: DebugError {
        .init()
    }
}
