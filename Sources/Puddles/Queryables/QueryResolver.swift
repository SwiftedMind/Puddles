import Foundation

/// A type that lets you answer a query made by a call to ``Puddles/Queryable/Trigger/query()``.
public struct QueryResolver<Result> {

    private let answerHandler: (Result) -> Void
    private let cancelHandler: (Error) -> Void

    /// A type that lets you answer a query made by a call to ``Puddles/Queryable/Trigger/query()``.
    init(
        answerHandler: @escaping (Result) -> Void,
        errorHandler: @escaping (Error) -> Void
    ) {
        self.answerHandler = answerHandler
        self.cancelHandler = errorHandler
    }

    /// Answers the query with a result.
    /// - Parameter result: The result of the query.
    public func answer(with result: Result) {
        answerHandler(result)
    }

    /// Answers the query with an optional result. If it is `nil`,  this will call ``Puddles/QueryResolver/cancelQuery()``.
    /// - Parameter result: The result of the query, as an optional.
    public func answer(withOptional optionalResult: Result?) {
        if let optionalResult {
            answerHandler(optionalResult)
        } else {
            cancelQuery()
        }
    }

    /// Answers the query.
    public func answer() where Result == Void {
        answerHandler(())
    }

    /// Answers the query by throwing an error.
    /// - Parameter error: The error to throw.
    public func answer(throwing error: Error) {
        cancelHandler(error)
    }

    /// Cancels the query by throwing a ``Puddles/QueryCancellationError`` error.
    public func cancelQuery() {
        cancelHandler(QueryCancellationError())
    }

    /// Cancels the query by throwing a `QueryInternalError.queryAutoCancel` error.
    ///
    /// This is an internal helper method to distinguish between a user canceled query and a system-cancelled query, like when the user uses a swipe gesture to close a sheet.
    func cancelQueryIfNeeded() {
        cancelHandler(QueryInternalError.queryAutoCancel)
    }
}
