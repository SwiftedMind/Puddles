import Combine
import SwiftUI

public protocol Provider: ObservableObject {}

public protocol IndependentProvider: Provider {
    @MainActor init()
}

/// A wrapper view that holds a `@StateObject` instance of a specified `provider` and provides it to its view builder `content` property.
///
/// This hides the StateObject and prevents the parent view from having to react to state changes, which is often an unnecessary waste of performance.
public struct WithProvider<P: Provider, Content: View>: View {

    @StateObject private var provider: P
    private var content: (_ provider: P) -> Content

    public init(
        _ provider: @autoclosure @escaping () -> P,
        @ViewBuilder content: @escaping (_ provider: P) -> Content
    ) {
        self._provider = .init(wrappedValue: provider())
        self.content = content
    }

    public init(
        _ provider: @escaping () -> P,
        @ViewBuilder content: @escaping (_ provider: P) -> Content
    ) {
        self._provider = .init(wrappedValue: provider())
        self.content = content
    }

    public init(
        _ providerType: P.Type,
        @ViewBuilder content: @escaping (_ provider: P) -> Content
    ) where P: IndependentProvider {
        self._provider = .init(wrappedValue: providerType.init())
        self.content = content
    }

    public var body: some View {
        content(provider)
    }
}
