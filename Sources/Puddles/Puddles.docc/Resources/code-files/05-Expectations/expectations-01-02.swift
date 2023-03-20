import SwiftUI
import Puddles

struct Root: Provider {
    @State var buttonTapCount: Int = 0

    var interface: Interface<Action>

    var entryView: some View {
        HomeView(
            interface: .consume(handleViewAction),
            state: .init(
                buttonTapCount: buttonTapCount
            )
        )
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Queryable Demo") {
                    interface.fire(.didTapShowQueryableDemo)
                }
            }
        }
    }

    @MainActor
    private func handleViewAction(_ action: HomeView.Action) {
        switch action {
        case .buttonTaped:
            buttonTapCount += 1
            if buttonTapCount == 42 {
                interface.fire(.didReachFortyTwo)
            }
        }
    }
}

extension Root {
    enum Action {
        case didReachFortyTwo
        case didTapShowQueryableDemo
    }
}
