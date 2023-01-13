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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Preview(HomeView.init, state: .mock) { action, $state in
            switch action {
            case .buttonTaped:
                state.buttonTapCount += 1
            }
        }
    }
}
