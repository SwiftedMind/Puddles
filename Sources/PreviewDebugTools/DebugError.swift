import Foundation

/// A helper type to throw mock errors.
public struct PreviewMockError: Error {
    public init() {}
}

public extension Error where Self == PreviewMockError {
    /// A helper type to throw mock errors.
    static var previewMock: PreviewMockError {
        .init()
    }
}
