import Foundation

/// A helper type to throw mock errors.
public struct PreviewMockError: Error, LocalizedError {
    public let message: String

    /// A helper type to throw mock errors.
    /// - Parameter message: An optional message you can add to the error object.
    public init(message: String = "") {
        self.message = message
    }

    /// A message for the mock error.
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
