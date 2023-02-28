import SwiftUI
import Puddles

struct Root: Coordinator {
    @State var buttonTapCount: Int = 0

    var interface: Interface<Action>

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
        switch action {
        case .buttonTaped:
            buttonTapCount += 1
            if buttonTapCount == 42 {
                interface.sendAction(.didReachFortyTwo)
            }
        }
    }
}

extension Root {
    enum Action {
        case didReachFortyTwo
    }
}
