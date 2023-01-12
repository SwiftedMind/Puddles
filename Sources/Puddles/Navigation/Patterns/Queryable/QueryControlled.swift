import SwiftUI

/// A navigation wrapper using a ``Puddles/Queryable`` to retrieve delayed asynchronous data from a contained presentation. See ``Puddles/Queryable`` for more information.
public struct QueryControlled<Result, Destination: NavigationPattern>: NavigationPattern {

    /// A binding to the ``Puddles/Queryable`` that drives this wrapper.
    var queryable: Queryable<Result>.Wrapper

    /// A closure that is given an `isActive` binding as well as a resolver for the query and returns a navigation pattern, like ``Puddles/Alert`` or ``Puddles/Sheet``.
    @ViewBuilder var destination: (_ isActive: Binding<Bool>, _ query: Queryable<Result>.Resolver) -> Destination

    /// A navigation wrapper using a ``Puddles/Queryable`` to retrieve delayed asynchronous data from a contained presentation. See ``Puddles/Queryable`` for more information.
    public init(
        by queryable: Queryable<Result>.Wrapper,
        @ViewBuilder destination: @escaping (_ isActive: Binding<Bool>, _ query: Queryable<Result>.Resolver) -> Destination
    ) {
        self.queryable = queryable
        self.destination = destination
    }
}

extension QueryControlled {
    public var body: some View {
        destination(queryable.isActive, queryable.resolver)
            .onChange(of: queryable.isActive.wrappedValue) { newValue in
                if newValue == false {
                    queryable.resolver.cancelQueryIfNeeded()
                }
            }
    }
}
