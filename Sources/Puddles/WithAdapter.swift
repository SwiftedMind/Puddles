import SwiftUI
#if canImport(Observation)
import Observation
#endif

public struct StateHosting<Observable, Content: View>: View {

    @State var observable: Observable
    var content: (_ observable: Observable) -> Content

    public init(
        _ observable: @escaping () -> Observable,
        @ViewBuilder content: @escaping (_ observable: Observable) -> Content
    ) {
        self._observable = .init(wrappedValue: observable())
        self.content = content
    }

#if swift(>=5.9)
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public init(
        _ observable: @escaping () -> Observable,
        @ViewBuilder content: @escaping (_ observable: Observable) -> Content
    ) where Observable: AnyObject, Observable: Observation.Observable {
        self._observable = .init(wrappedValue: observable())
        self.content = content
    }
#endif

    public var body: some View {
        content(observable)
    }
}

public struct StateObjectHosting<Observable: ObservableObject, Content: View>: View where Observable: ObservableObject {

    @StateObject var observable: Observable
    var content: (_ observable: Observable) -> Content

    public init(
        _ observable: @escaping () -> Observable,
        @ViewBuilder content: @escaping (_ observable: Observable) -> Content
    ) {
        self._observable = .init(wrappedValue: observable())
        self.content = content
    }

    public var body: some View {
        content(observable)
    }
}
