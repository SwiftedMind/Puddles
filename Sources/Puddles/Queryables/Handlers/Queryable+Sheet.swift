import SwiftUI

// MARK: - Queryable

public extension View {
    func queryableSheet<Result, Content: View>(
        controlledBy queryable: Queryable<Result>.Trigger,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (_ query: QueryResolver<Result>) -> Content
    ) -> some View {
        sheet(isPresented: queryable.isActive, onDismiss: onDismiss) {
            content(queryable.resolver)
                .onDisappear {
                    queryable.resolver.cancelQueryIfNeeded()
                }
        }
    }
}

// MARK: - Queryable Item

public extension View {
    func queryableSheet<Item, Result, Content: View>(
        controlledBy queryable: QueryableItem<Item, Result>.Trigger,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (_ item: Item, _ query: QueryResolver<Result>) -> Content
    ) -> some View where Item: Identifiable {
        sheet(item: queryable.item, onDismiss: onDismiss) { item in
            content(item, queryable.resolver)
                .onDisappear {
                    queryable.resolver.cancelQueryIfNeeded()
                }
        }
    }
}
