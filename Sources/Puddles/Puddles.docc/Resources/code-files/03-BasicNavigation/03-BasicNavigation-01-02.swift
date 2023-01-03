import SwiftUI
import Puddles

struct Root: Coordinator {
    @StateObject var interface: HomeView.Interface = .init()

    @State private var isShowingSheet: Bool = false

    var entryView: some View {
        HomeView(interface: interface)
    }

    func navigation() -> some NavigationPattern {
        // Empty for now
    }

    func handleAction(_ action: Action) async {
        switch action {
        case .buttonTapped:
            interface.buttonTapCount += 1
            if interface.buttonTapCount == 42 {
                isShowingSheet = true
            }
        }
    }
}
