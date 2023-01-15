import SwiftUI
import Puddles

struct Root: Coordinator {
    @StateObject var viewInterface: Interface<HomeView.Action> = .init()
    @State var buttonTapCount: Int = 0

    @State private var isShowingPage: Bool = false

    var viewState: HomeView.ViewState {
        .init(
            buttonTapCount: buttonTapCount
        )
    }

    var entryView: some View {
        HomeView(interface: viewInterface, state: viewState)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
    }

    func modify(coordinator: CoordinatorContent) -> some View {
        NavigationStack {
            coordinator
        }
    }

    func navigation() -> some NavigationPattern {
        Push(isActive: $isShowingPage) {
            Text("🎉")
                .font(.largeTitle)
                .navigationTitle("Yay!")
        }
    }

    func interfaces() -> some InterfaceObservation {
        InterfaceObserver(viewInterface) { action in
            handleViewAction(action)
        }
    }

    private func handleViewAction(_ action: Action) {
        switch action {
        case .buttonTapped:
            buttonTapCount += 1
            if buttonTapCount == 42 {
                isShowingPage = true
            }
        }
    }

}
