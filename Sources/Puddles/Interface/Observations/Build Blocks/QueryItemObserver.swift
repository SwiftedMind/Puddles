import SwiftUI

public struct QueryItemObserver<Item, Result>: InterfaceObservation {

    var queryable: QueryableItem<Item, Result>.Trigger
    var queryHandler: @MainActor (_ item: Item, _ resolver: QueryResolver<Result>) -> Void

    public init(
        queryable: QueryableItem<Item, Result>.Trigger,
        queryHandler: @MainActor @escaping (_ item: Item, _ resolver: QueryResolver<Result>) -> Void
    ) {
        self.queryable = queryable
        self.queryHandler = queryHandler
    }
}

public extension QueryItemObserver {

    @MainActor
    var body: some View {
        Color.clear
            .onChange(of: NilEquatableWrapper(item: queryable.item.wrappedValue)) { wrapped in
                if let item = wrapped.item {
                    queryHandler(item, queryable.resolver)
                } else {
                    queryable.resolver.cancelQueryIfNeeded()
                }
            }
    }
}

/// Helper type allowing for `nil` checks in SwiftUI without losing the checked item.
///
/// This allows to support item types that are not `Equatable`.
fileprivate struct NilEquatableWrapper<Item>: Equatable {

    let item: Item?

    static func == (lhs: NilEquatableWrapper<Item>, rhs: NilEquatableWrapper<Item>) -> Bool {
        if lhs.item == nil {
            return rhs.item == nil
        } else {
            return rhs.item != nil
        }
    }

}
