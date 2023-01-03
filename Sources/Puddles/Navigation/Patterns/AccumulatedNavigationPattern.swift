import SwiftUI

/// Internal helper type used to construct the navigation in the ``Puddles/Coordinator/NavigationBuilder`` result builder.
struct AccumulatedNavigationPattern<Pattern: NavigationPattern, Next: NavigationPattern>: NavigationPattern {

    var accumulated: Pattern
    var next: Next

    @inlinable var body: some View {
        accumulated.background(next)
    }
}
