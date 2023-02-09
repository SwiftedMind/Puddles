import SwiftUI

public extension View {
    func queryableHandler<Item, Result>(
        controlledBy queryable: QueryableItem<Item, Result>.Trigger,
        queryHandler: @escaping (_ item: Item, _ query: QueryResolver<Result>) -> Void
    ) -> some View {
        self
            .onChange(of: NilEquatableWrapper(item: queryable.item.wrappedValue)) { wrapped in
                if let item = wrapped.item {
                    queryHandler(item, queryable.resolver)
                } else {
                    queryable.resolver.cancelQueryIfNeeded()
                }
            }
    }
}

public extension View {
    func queryableHandler<Result>(
        controlledBy queryable: Queryable<Result>.Trigger,
        queryHandler: @escaping (_ query: QueryResolver<Result>) -> Void
    ) -> some View {
        self
            .onChange(of: queryable.isActive.wrappedValue) { newValue in
                if newValue {
                    queryHandler(queryable.resolver)
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

    static func ==(lhs: NilEquatableWrapper<Item>, rhs: NilEquatableWrapper<Item>) -> Bool {
        if lhs.item == nil {
            return rhs.item == nil
        } else {
            return rhs.item != nil
        }
    }
}
