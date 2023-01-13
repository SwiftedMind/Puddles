import SwiftUI
import Puddles

struct Root: Coordinator {
    @State var buttonTapCount: Int = 0

    var viewState: HomeView.ViewState {
        .init(
            buttonTapCount: buttonTapCount
        )
    }

    var entryView: some View {
        HomeView(state: viewState)
    }

    func navigation() -> some NavigationPattern {
        // Empty for now
    }

    func interfaces() -> some InterfaceObservation {
        // Empty for now
    }

}
