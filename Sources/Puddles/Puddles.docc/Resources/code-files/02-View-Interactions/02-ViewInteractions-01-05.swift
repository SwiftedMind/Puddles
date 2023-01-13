import SwiftUI
import Puddles

struct Root: Coordinator {
    @StateObject var viewInterface: Interface<HomeView.Action> = .init()
    @State var buttonTapCount: Int = 0

    var viewState: HomeView.ViewState {
        .init(
            buttonTapCount: buttonTapCount
        )
    }

    var entryView: some View {
        HomeView(interface: viewInterface, state: viewState)
    }

    func navigation() -> some NavigationPattern {
        // Empty for now
    }

    func interfaces() -> some InterfaceObservation {
        // Empty for now
    }

}
