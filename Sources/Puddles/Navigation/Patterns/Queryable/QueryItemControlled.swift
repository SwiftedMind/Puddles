import SwiftUI

/// A navigation wrapper using a ``Puddles/Queryable`` to retrieve delayed asynchronous data from a contained presentation. See ``Puddles/Queryable`` for more information.
public struct QueryItemControlled<Item, Result, Destination: NavigationPattern>: NavigationPattern {

    /// A binding to the ``Puddles/Queryable`` that drives this wrapper.
    var queryable: QueryableItem<Item, Result>.Trigger

    /// A closure that is given an `isActive` binding as well as a resolver for the query and returns a navigation pattern, like ``Puddles/Alert`` or ``Puddles/Sheet``.
    @ViewBuilder var destination: (_ item: Binding<Item?>, _ query: QueryResolver<Result>) -> Destination

    /// A navigation wrapper using a ``Puddles/Queryable`` to retrieve delayed asynchronous data from a contained presentation. See ``Puddles/Queryable`` for more information.
    public init(
        by queryable: QueryableItem<Item, Result>.Trigger,
        @ViewBuilder destination: @escaping (_ item: Binding<Item?>, _ query: QueryResolver<Result>) -> Destination
    ) {
        self.queryable = queryable
        self.destination = destination
    }
}

extension QueryItemControlled {
    public var body: some View {
        destination(queryable.item, queryable.resolver)
            .onChange(of: queryable.item.wrappedValue == nil) { isNil in
                if isNil {
                    queryable.resolver.cancelQueryIfNeeded()
                }
            }
    }
}
