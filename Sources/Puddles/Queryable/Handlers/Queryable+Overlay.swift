import SwiftUI

public extension View {
    func queryableOverlay<Item, Result, Content: View>(
        controlledBy queryable: QueryableItem<Item, Result>.Trigger,
        animation: Animation? = nil,
        @ViewBuilder content: @escaping (_ item: Item, _ query: QueryResolver<Result>) -> Content
    ) -> some View where Item: Identifiable {
        self
            .overlay {
                ZStack {
                    if let item = queryable.item.wrappedValue {
                        content(item, queryable.resolver)
                            .background {
                                ViewLifetimeHelper {

                                } onDeinit: {
                                    queryable.resolver.cancelQueryIfNeeded()
                                }
                            }
                    }
                }
                .animation(animation, value: queryable.item.wrappedValue == nil)
            }
    }
}

public extension View {
    func queryableOverlay<Result, Content: View>(
        controlledBy queryable: Queryable<Result>.Trigger,
        animation: Animation? = nil,
        @ViewBuilder content: @escaping (_ query: QueryResolver<Result>) -> Content
    ) -> some View {
        self
            .overlay {
                ZStack {
                    if queryable.isActive.wrappedValue {
                        content(queryable.resolver)
                            .background {
                                ViewLifetimeHelper {

                                } onDeinit: {
                                    queryable.resolver.cancelQueryIfNeeded()
                                }
                            }
                    }
                }
                .animation(animation, value: queryable.isActive.wrappedValue)
            }
    }
}
