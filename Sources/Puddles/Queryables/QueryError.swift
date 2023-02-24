import Foundation

public struct QueryCancellationError: Swift.Error {}

enum QueryInternalError: Swift.Error {
    case queryAutoCancel
}
