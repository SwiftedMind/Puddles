import Foundation

public struct PreviewMockError: Error {
    public init() {}
}

public extension Error where Self == PreviewMockError {
    static var previewMock: PreviewMockError {
        .init()
    }
}
