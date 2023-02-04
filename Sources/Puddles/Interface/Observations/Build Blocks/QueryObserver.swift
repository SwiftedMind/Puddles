import SwiftUI

public struct QueryObserver<Result>: InterfaceObservation {

    var queryable: Queryable<Result>.Trigger
    var queryHandler: @MainActor (_ resolver: QueryResolver<Result>) -> Void

    public init(
        queryable: Queryable<Result>.Trigger,
        queryHandler: @MainActor @escaping (_ resolver: QueryResolver<Result>) -> Void
    ) {
        self.queryable = queryable
        self.queryHandler = queryHandler
    }
}

public extension QueryObserver {

    @MainActor
    var body: some View {
        Color.clear
            .onChange(of: queryable.isActive.wrappedValue) { newValue in
                if newValue {
                    queryHandler(queryable.resolver)
                } else {
                    queryable.resolver.cancelQueryIfNeeded()
                }
            }
    }
}

