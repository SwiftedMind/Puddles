import SwiftUI

/// A NavigationBuilder allows for a convenient creation of a list of navigation patterns, like `sheet`s, `NavigationLinks` or `alert`s.
///
/// It is similar to SwiftUI's `@ViewBuilder` in that you can simply list all the needed navigation patterns and the `Coordinator` will turn that into native view destinations.
@resultBuilder public struct NavigationBuilder {

    public static func buildBlock() -> some NavigationPattern {
        EmptyNavigation()
    }

    @available(*, unavailable, message: "Please use a NavigationPattern")
    public static func buildPartialBlock(
        first content: some View
    ) -> some View {
        content
    }

    public static func buildPartialBlock(
        first content: some NavigationPattern
    ) -> some NavigationPattern {
        content
    }

    public static func buildPartialBlock(
        accumulated: some NavigationPattern,
        next: some NavigationPattern
    ) -> some NavigationPattern {
        AccumulatedNavigationPattern(accumulated: accumulated, next: next)
    }
}
