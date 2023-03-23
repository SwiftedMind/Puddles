import SwiftUI

// MARK: - Queryable

public extension View {

    /// Shows an alert controlled by a ``Puddles/QueryableWithInput``.
    ///
    /// The alert is automatically presented when a query is ongoing.
    func queryableAlert<Result, Actions: View, Message: View>(
        controlledBy queryable: Queryable<Result>.Trigger,
        title: String,
        @ViewBuilder actions: @escaping (_ query: QueryResolver<Result>) -> Actions,
        @ViewBuilder message: @escaping () -> Message
    ) -> some View {
        alert(title, isPresented: queryable.isActive) {
            actions(queryable.resolver)
        } message: {
            message()
        }
        .onChange(of: queryable.isActive.wrappedValue) { newValue in
            if !newValue {
                queryable.resolver.cancelQueryIfNeeded()
            }
        }
    }
}

// MARK: - Queryable Item

public extension View {
    
    /// Shows an alert controlled by a ``Puddles/QueryableWithInput``.
    ///
    /// The alert is automatically presented when a query is ongoing.
    func queryableAlert<Item, Result, Actions: View, Message: View>(
        controlledBy queryable: QueryableWithInput<Item, Result>.Trigger,
        title: String,
        @ViewBuilder actions: @escaping (_ item: Item, _ query: QueryResolver<Result>) -> Actions,
        @ViewBuilder message: @escaping (_ item: Item) -> Message
    ) -> some View {
        alert(
            title,
            isPresented: queryable.item.mappedToBool(),
            presenting: queryable.item.wrappedValue
        ) { item in
            actions(item, queryable.resolver)
        } message: { item in
            message(item)
        }
        .onChange(of: NilEquatableWrapper(item: queryable.item)) { wrapped in
            if wrapped.item == nil {
                queryable.resolver.cancelQueryIfNeeded()
            }
        }
    }
}
