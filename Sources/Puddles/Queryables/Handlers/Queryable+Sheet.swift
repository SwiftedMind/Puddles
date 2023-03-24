import SwiftUI

// MARK: - Queryable

public extension View {

    /// Presents a sheet controlled by a ``Puddles/Queryable``
    func queryableSheet<Result, Content: View>(
        controlledBy queryable: Queryable<Void, Result>.Trigger,
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

private struct QueryableSheet<Item, Result, SheetContent: View>: ViewModifier where Item: Identifiable {

    @State private var presentingQueries: Set<UUID> = .init()

    var queryable: Queryable<Item, Result>.Trigger
    var onDismiss: (() -> Void)? = nil
    @ViewBuilder var sheetContent: (_ item: Item, _ query: QueryResolver<Result>) -> SheetContent

    func body(content: Content) -> some View {
        content
            .sheet(item: queryable.item, onDismiss: onDismiss) { item in
                sheetContent(item, queryable.resolver)
                    .onDisappear {
                        queryable.resolver.cancelQueryIfNeeded()
                    }
            }
    }
}

public extension View {

    /// Presents a sheet controlled by a ``Puddles/QueryableWithInput``.
    func queryableSheet<Item, Result, Content: View>(
        controlledBy queryable: Queryable<Item, Result>.Trigger,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (_ item: Item, _ query: QueryResolver<Result>) -> Content
    ) -> some View where Item: Identifiable {
        modifier(QueryableSheet(queryable: queryable, onDismiss: onDismiss, sheetContent: content))
    }
}
