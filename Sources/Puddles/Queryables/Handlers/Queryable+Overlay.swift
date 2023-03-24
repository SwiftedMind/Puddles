import SwiftUI

// MARK: - Queryable

public extension View {

    /// Shows an overlay controlled by a ``Puddles/Queryable``.
    ///
    /// The overlay is automatically presented when a query is ongoing. 
    func queryableOverlay<Result, Content: View>(
        controlledBy queryable: Queryable<Void, Result>.Trigger,
        animation: Animation? = nil,
        @ViewBuilder content: @escaping (_ query: QueryResolver<Result>) -> Content
    ) -> some View {
        overlay {
            ZStack {
                if queryable.isActive.wrappedValue {
                    content(queryable.resolver)
                        .onDisappear {
                            queryable.resolver.cancelQueryIfNeeded()
                        }
                }
            }
            .animation(animation, value: queryable.isActive.wrappedValue)
        }
    }
}



public extension View {

    /// Shows an overlay controlled by a ``Puddles/QueryableWithInput``.
    ///
    /// The overlay is automatically presented when a query is ongoing.
    func queryableOverlay<Item, Result, Content: View>(
        controlledBy queryable: Queryable<Item, Result>.Trigger,
        animation: Animation? = nil,
        @ViewBuilder content: @escaping (_ item: Item, _ query: QueryResolver<Result>) -> Content
    ) -> some View {
        overlay {
            ZStack {
                if let item = queryable.item.wrappedValue {
                    content(item, queryable.resolver)
                        .onDisappear {
                            queryable.resolver.cancelQueryIfNeeded()
                        }
                }
            }
            .animation(animation, value: queryable.item.wrappedValue == nil)
        }
    }
}
