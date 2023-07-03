import SwiftUI

public struct StateObjectHosting<Observable: ObservableObject, Content: View>: View {

    @StateObject var observable: Observable
    var content: (Observable) -> Content

    public init(
        _ hostedState: @escaping () -> Observable,
        @ViewBuilder content: @escaping (_ hostedState: Observable) -> Content
    ) {
        self._observable = .init(wrappedValue: hostedState())
        self.content = content
    }

    public var body: some View {
        content(observable)
    }
}
