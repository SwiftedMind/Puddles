import SwiftUI

@available(iOS 16.0, *)
public extension View {
    func queryablePush<Item, Result, Content: View>(
        controlledBy queryable: QueryableItem<Item, Result>.Trigger,
        @ViewBuilder content: @escaping (_ item: Item, _ query: QueryResolver<Result>) -> Content
    ) -> some View where Item: Identifiable {
        self
            .navigationDestination(isPresented: queryable.item.mappedToBool()) {
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
    }
}

@available(iOS 16.0, *)
public extension View {
    func queryablePush<Result, Content: View>(
        controlledBy queryable: Queryable<Result>.Trigger,
        @ViewBuilder content: @escaping (_ query: QueryResolver<Result>) -> Content
    ) -> some View {
        self
            .navigationDestination(isPresented: queryable.isActive) {
                content(queryable.resolver)
                    .background {
                        ViewLifetimeHelper {

                        } onDeinit: {
                            queryable.resolver.cancelQueryIfNeeded()
                        }
                    }
            }
    }
}
