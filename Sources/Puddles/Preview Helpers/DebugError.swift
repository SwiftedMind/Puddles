import Foundation

/// A helper type to throw mock errors.
public struct PreviewMockError: Error, LocalizedError {
    public let message: String
    public init(message: String = "") {
        self.message = message
    }

    public var errorDescription: String? {
        message
    }
}

public extension Error where Self == PreviewMockError {
    /// A helper type to throw mock errors.
    static var previewMock: PreviewMockError {
        .init()
    }
}
