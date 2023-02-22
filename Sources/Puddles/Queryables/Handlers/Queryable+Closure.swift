import SwiftUI

// MARK: - Queryable

public extension View {
    func queryableHandler<Result>(
        controlledBy queryable: Queryable<Result>.Trigger,
        queryHandler: @escaping (_ query: QueryResolver<Result>) -> Void
    ) -> some View {
        self
            .onChange(of: queryable.isActive.wrappedValue) { wrapped in
                if wrapped {
                    queryHandler(queryable.resolver)
                } else {
                    queryable.resolver.cancelQueryIfNeeded()
                }
            }
    }
}


// MARK: - Queryable Item

public extension View {
    func queryableHandler<Item, Result>(
        controlledBy queryable: QueryableItem<Item, Result>.Trigger,
        queryHandler: @escaping (_ item: Item, _ query: QueryResolver<Result>) -> Void
    ) -> some View {
        self
            .onChange(of: NilEquatableWrapper(item: queryable.item)) { wrapped in
                if let item = wrapped.item?.wrappedValue {
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

    static func ==(lhs: NilEquatableWrapper<Item>, rhs: NilEquatableWrapper<Item>) -> Bool {
        if lhs.item == nil {
            return rhs.item == nil
        } else {
            return rhs.item != nil
        }
    }
}
