import SwiftUI
import Puddles

struct Root: Coordinator {
    @StateObject var interface: HomeView.Interface = .init()

    @State private var isShowingPage: Bool = false

    var entryView: some View {
        HomeView(interface: interface)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
    }

    func modify(coordinator: CoordinatorContent) -> some View {
        NavigationView {
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

    func handleAction(_ action: Action) async {
        switch action {
        case .buttonTapped:
            interface.buttonTapCount += 1
            if interface.buttonTapCount == 42 {
                isShowingPage = true
            }
        }
    }
}
