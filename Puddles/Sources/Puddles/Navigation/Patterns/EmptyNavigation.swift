import SwiftUI

/// An empty navigation pattern.
///
/// This is used by the ``Puddles/NavigationBuilder`` result builder when an empty closure is provided.
public struct EmptyNavigation: NavigationPattern {
    public var body: some View {
        EmptyView()
    }
}
