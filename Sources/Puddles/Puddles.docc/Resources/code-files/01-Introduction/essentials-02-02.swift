import SwiftUI
import Puddles

struct HomeView: View {
    let state: ViewState

    var body: some View {
        Text("Hello, World")
    }

}

extension HomeView {
    struct ViewState {
        var buttonTapCount: Int = 0
    }
}
