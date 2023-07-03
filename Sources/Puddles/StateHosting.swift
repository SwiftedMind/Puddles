import SwiftUI
#if canImport(Observation)
import Observation
#endif

public struct StateHosting<Observable, Content: View>: View {

    @State var observable: Observable
    var content: (Binding<Observable>) -> Content

    public init(
        _ hostedState: @escaping () -> Observable,
        @ViewBuilder content: @escaping (Binding<Observable>) -> Content
    ) {
        self._observable = .init(wrappedValue: hostedState())
        self.content = content
    }

    public init(
        _ hostedState: Observable,
        @ViewBuilder content: @escaping (Binding<Observable>) -> Content
    ) {
        self._observable = .init(wrappedValue: hostedState)
        self.content = content
    }

#if swift(>=5.9)
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public init(
        _ hostedState: @escaping () -> Observable,
        @ViewBuilder content: @escaping (Binding<Observable>) -> Content
    ) where Observable: AnyObject, Observable: Observation.Observable {
        self._observable = .init(wrappedValue: hostedState())
        self.content = content
    }
#endif

    public var body: some View {
        content($observable)
    }
}
