import SwiftUI

/// A SwiftUI view that takes an item container provided at initialization and maintains its
/// initial state for the lifetime of the view. This view can be used to ensure a particular
/// state remains constant while working with SwiftUI views, which might rebuild or reevaluate
/// their content at different times.
struct StableItemContainerView<Content: View, Input, Result>: View where Input: Sendable, Result: Sendable {

    /// A private state property to store the initial item container.
    @State private var itemContainer: QueryableManager<Input, Result>.ItemContainer

    /// A closure that defines the content of the view, accepting the item container as its argument.
    private let content: (_ itemContainer: QueryableManager<Input, Result>.ItemContainer) -> Content

    /// Initializes a new `StableItemContainerView` with the given item container and a closure
    /// that defines the content of the view.
    ///
    /// - Parameters:
    ///   - itemContainer: The item container that will be provided to the content of the view
    ///                    and maintained for the view's lifetime.
    ///   - content: A closure that defines the content of the view, which accepts the item container
    ///              as its argument.
    init(
        itemContainer: QueryableManager<Input, Result>.ItemContainer,
        @ViewBuilder content: @escaping (_ itemContainer: QueryableManager<Input, Result>.ItemContainer) -> Content
    ) {
        _itemContainer = .init(initialValue: itemContainer)
        self.content = content
    }

    var body: some View {
        content(itemContainer)
    }
}
