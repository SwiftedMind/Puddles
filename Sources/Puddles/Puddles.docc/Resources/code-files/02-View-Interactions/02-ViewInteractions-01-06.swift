import SwiftUI
import Puddles

struct Root: Provider {
    @State var buttonTapCount: Int = 0

    var entryView: some View {
        HomeView(
            interface: .consume(handleViewAction),
            state: .init(
                buttonTapCount: buttonTapCount
            )
        )
    }

    @MainActor
    private func handleViewAction(_ action: HomeView.Action) {
        switch action {
        case .buttonTaped:
            buttonTapCount += 1
        }
    }
}
