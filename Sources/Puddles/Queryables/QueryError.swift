import Foundation

public struct QueryCancellationError: Swift.Error {}

public enum QueryError: Swift.Error {
    case unknown
}

enum QueryInternalError: Swift.Error {
    case queryAutoCancel
}
