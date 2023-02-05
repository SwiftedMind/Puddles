import SwiftUI

/// A navigation wrapper using a ``Puddles/Queryable`` to retrieve delayed asynchronous data from a contained presentation. See ``Puddles/Queryable`` for more information.
public struct QueryItemControlled<Item, Result, Destination: View>: ViewModifier  where Item: Identifiable {

    /// A reference to the ``Puddles/Queryable`` that drives this wrapper.
    var queryable: QueryableItem<Item, Result>.Trigger

    /// A closure that is given an `isActive` binding as well as a resolver for the query and returns a navigation pattern, like ``Puddles/Alert`` or ``Puddles/Sheet``.
    @ViewBuilder var destination: (_ item: Item, _ query: QueryResolver<Result>) -> Destination

    /// A navigation wrapper using a ``Puddles/Queryable`` to retrieve delayed asynchronous data from a contained presentation. See ``Puddles/Queryable`` for more information.
    public init(
        by queryable: QueryableItem<Item, Result>.Trigger,
        @ViewBuilder destination: @escaping (_ item: Item, _ query: QueryResolver<Result>) -> Destination
    ) {
        self.queryable = queryable
        self.destination = destination
    }
}

extension QueryItemControlled {

    public func body(content: Content) -> some View {
        content
            .sheet(item: queryable.item, onDismiss: nil) { item in
                destination(item, queryable.resolver)
                    .overlay {
                        Text(verbatim: "\(queryable.item.wrappedValue)")
                            .onTapGesture {
                                queryable.item.wrappedValue = nil
                            }
                    }
            }
            .onChange(of: queryable.item.wrappedValue == nil) { isNil in
                if isNil {
                    queryable.resolver.cancelQueryIfNeeded()
                }
            }
    }
}

public extension View {
    func queryableSheet<Item, Result, Content: View>(
        controlledBy queryable: QueryableItem<Item, Result>.Trigger,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (_ item: Item, _ query: QueryResolver<Result>) -> Content
    ) -> some View where Item: Identifiable {
        modifier(QueryItemControlled(by: queryable, destination: content))
    }
}
