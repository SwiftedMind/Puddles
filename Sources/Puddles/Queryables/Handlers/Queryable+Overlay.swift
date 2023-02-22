import SwiftUI

// MARK: - Queryable

public extension View {
    func queryableOverlay<Result, Content: View>(
        controlledBy queryable: Queryable<Result>.Trigger,
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

// MARK: - Queryable Item

public extension View {
    func queryableOverlay<Item, Result, Content: View>(
        controlledBy queryable: QueryableItem<Item, Result>.Trigger,
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
