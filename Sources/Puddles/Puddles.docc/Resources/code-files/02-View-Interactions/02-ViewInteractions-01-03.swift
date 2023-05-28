import SwiftUI
import Puddles

struct HomeView: View {
    var interface: Interface<Action>
    var state: ViewState

    var body: some View {
        VStack {
            Text("Button tapped \(state.buttonTapCount) times.")
            Button("Tap Me") {
                interface.send(.buttonTapped)
            }
        }
    }
}

extension HomeView {
    struct ViewState {
        var buttonTapCount: Int = 0
    }

    enum Action {
        case buttonTapped
    }
}
