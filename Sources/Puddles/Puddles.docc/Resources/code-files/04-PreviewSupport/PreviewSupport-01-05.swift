import SwiftUI
import Puddles

struct HomeView: View {
    var interface: Interface<Action>
    var state: ViewState

    var body: some View {
        VStack {
            Text("Button tapped \(state.buttonTapCount) times.")
            Button("Tap Me") {
                interface.send(.buttonTaped)
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
        ViewPreview(HomeView.init, state: .mock) { action, $state in
            switch action {
            case .buttonTaped:
                state.buttonTapCount += 1
            }
        }
        .onStart { $state in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            state.buttonTapCount = 40
        }
        .overlay(alignment: .bottom) { $state in
            DebugButton("Reset") {
                state.buttonTapCount = 0
            }
        }
    }
}
