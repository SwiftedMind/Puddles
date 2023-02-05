import Foundation

/// Internal helper type that stores the `CheckedContinuation`.
///
/// To prevent data races, it is an actor.
final actor QueryBuffer<Result> {
    private let queryConflictPolicy: QueryConflictPolicy
    private var continuation: CheckedContinuation<Result, Swift.Error>?

    init(queryConflictPolicy: QueryConflictPolicy) {
        self.queryConflictPolicy = queryConflictPolicy
    }

    var hasContinuation: Bool {
        continuation != nil
    }

    @discardableResult
    func storeContinuation(_ continuation: CheckedContinuation<Result, Swift.Error>) -> Bool {
        if self.continuation != nil {
            switch queryConflictPolicy {
            case .cancelPreviousQuery:
                logger.warning("Cancelling previous query of »\(Result.self, privacy: .public)« to allow new query.")
                self.continuation?.resume(throwing: QueryCancellationError())
                self.continuation = nil
                return false
            case .cancelNewQuery:
                logger.warning("Cancelling new query of »\(Result.self, privacy: .public)« because another query is ongoing.")
                continuation.resume(throwing: QueryCancellationError())
                return false
            }
        }

        self.continuation = continuation
        return true
    }

    func resumeContinuation(returning result: Result) {
        continuation?.resume(returning: result)
        continuation = nil
    }

    func resumeContinuation(throwing error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
