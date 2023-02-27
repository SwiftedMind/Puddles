import SwiftUI
import Puddles

struct Root: Coordinator {
    @State var buttonTapCount: Int = 0

    var entryView: some View {
        HomeView(
            interface: .handled(by: handleViewAction),
            state: .init(
                buttonTapCount: buttonTapCount
            )
        )
    }

    @MainActor
    private func handleViewAction(_ action: HomeView.Action) {
        // Handle view actions
    }
}
