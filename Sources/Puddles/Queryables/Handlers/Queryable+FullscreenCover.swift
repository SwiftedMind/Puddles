import SwiftUI

// MARK: - Queryable

@available(macOS, unavailable)
public extension View {

    /// Shows a fullscreen cover controlled by a ``Puddles/Queryable``.
    ///
    /// The fullscreen cover is automatically presented when a query is ongoing.
    func queryableFullScreenCover<Result, Content: View>(
        controlledBy queryable: Queryable<Result>.Trigger,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (_ query: QueryResolver<Result>) -> Content
    ) -> some View {
        fullScreenCover(isPresented: queryable.isActive, onDismiss: onDismiss) {
            content(queryable.resolver)
                .onDisappear {
                    queryable.resolver.cancelQueryIfNeeded()
                }
        }
    }
}

// MARK: - Queryable Item

@available(macOS, unavailable)
public extension View {

    /// Shows a fullscreen cover controlled by a ``Puddles/QueryableWithInput``.
    ///
    /// The fullscreen cover is automatically presented when a query is ongoing.
    func queryableFullScreenCover<Item, Result, Content: View>(
        controlledBy queryable: QueryableWithInput<Item, Result>.Trigger,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (_ item: Item, _ query: QueryResolver<Result>) -> Content
    ) -> some View where Item: Identifiable {
        fullScreenCover(item: queryable.item, onDismiss: onDismiss) { item in
            content(item, queryable.resolver)
                .onDisappear {
                    queryable.resolver.cancelQueryIfNeeded()
                }
        }
    }
}
