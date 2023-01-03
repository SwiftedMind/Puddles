import SwiftUI

/// Wrapper protocol around `View` to limit the scope of allowed types within the ``Puddles/NavigationBuilder`` result builder.
public protocol NavigationPattern: View {}
