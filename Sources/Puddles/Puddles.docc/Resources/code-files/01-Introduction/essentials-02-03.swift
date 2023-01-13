import SwiftUI
import Puddles

struct HomeView: View {
    let state: ViewState

    var body: some View {
        VStack {
            Text("Button tapped \(state.buttonTapCount) times.")
            Button("Tap Me") {
                
            }
        }
    }

}

extension HomeView {
    struct ViewState {
        var buttonTapCount: Int = 0
    }
}
