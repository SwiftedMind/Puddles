import Foundation

/// Helper type allowing for `nil` checks in SwiftUI without losing the checked item.
///
/// This allows to support item types that are not `Equatable`.
struct NilEquatableWrapper<Item>: Equatable {
    let item: Item?

    static func ==(lhs: NilEquatableWrapper<Item>, rhs: NilEquatableWrapper<Item>) -> Bool {
        if lhs.item == nil {
            return rhs.item == nil
        } else {
            return rhs.item != nil
        }
    }
}
