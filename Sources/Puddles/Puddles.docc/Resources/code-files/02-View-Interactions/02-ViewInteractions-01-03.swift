import SwiftUI
import Puddles

struct HomeView: View {
    @ObservedObject var interface: Interface<Action>
    let state: ViewState

    var body: some View {
        VStack {
            Text("Button tapped \(state.buttonTapCount) times.")
            Button("Tap Me") {
                interface.sendAction(.buttonTapped)
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
