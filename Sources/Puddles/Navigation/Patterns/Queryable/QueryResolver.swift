import Foundation

/// A type that lets you answer a query made by a call to ``Puddles/Queryable/Wrapper/query()``.
public class QueryResolver<Result> {

    private let answerHandler: (Result) -> Void
    private let cancelHandler: (Error) -> Void

    init(
        answerHandler: @escaping (Result) -> Void,
        errorHandler: @escaping (Error) -> Void
    ) {
        self.answerHandler = answerHandler
        self.cancelHandler = errorHandler
    }

    /// Answer the query with a result.
    /// - Parameter result: The result of the query.
    public func answer(with result: Result) {
        answerHandler(result)
    }

    /// Answer the query with an optional result. If it is `nil`,  this will call ``Puddles/Queryable/Resolver/cancelQuery()``.
    /// - Parameter result: The result of the query, as an optional.
    public func answer(withOptional optionalResult: Result?) {
        if let optionalResult {
            answerHandler(optionalResult)
        } else {
            cancelQuery()
        }
    }

    /// Answer the query.
    public func answer() where Result == Void {
        answerHandler(())
    }

    /// Answer the query by throwing an error.
    /// - Parameter error: The error to throw.
    public func answer(throwing error: Error) {
        cancelHandler(error)
    }

    /// Cancel the query by throwing a ``Puddles/QueryError/queryCancelled`` error.
    public func cancelQuery() {
        cancelHandler(QueryCancellationError())
    }

    /// Cancel the query by throwing a `QueryInternalError.queryAutoCancel` error.
    ///
    /// This is an internal helper method to distnguish between a user canceled query and a system-cancelled query. See ``Puddles/QueryControlled``'s ``Puddles/QueryControlled/body`` for an example.
    func cancelQueryIfNeeded() {
        cancelHandler(QueryInternalError.queryAutoCancel)
    }
}

enum QueryInternalError: Swift.Error {
    case queryAutoCancel
}
