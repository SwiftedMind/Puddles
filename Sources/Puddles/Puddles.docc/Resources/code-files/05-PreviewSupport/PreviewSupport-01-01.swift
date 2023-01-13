import SwiftUI
import Puddles

struct HomeView: View {
    @ObservedObject var interface: Interface<Action>
    let state: ViewState

    var body: some View {
        VStack {
            Text("Button tapped \(state.buttonTapCount) times.")
            Button("Tap Me") {
                interface.sendAction(.buttonTaped)
            }
        }
    }

}

extension HomeView {

    struct ViewState {
        var buttonTapCount: Int

        init(buttonTapCount: Int = 0) {
            self.buttonTapCount = buttonTapCount
        }

        static var mock: ViewState {
            .init(buttonTapCount: 10)
        }
    }

    enum Action {
        case buttonTaped
    }
}
