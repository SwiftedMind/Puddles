import SwiftUI
import Puddles

struct RootNavigator: Navigator {
    @State private var path: [Path] = []

    var entryView: some View {
        NavigationStack(path: $path) {
            Root(interface: .consume(handleRootAction))
        }
    }

    func applyTargetState(_ state: TargetState) {
        switch state {
        case .reset:
            path = []
        case .showPage:
            path = [.page]
        }
    }

    @MainActor
    private func handleRootAction(_ action: Root.Action) {
        switch action {
        case .didReachFortyTwo:
            applyTargetState(.showPage)
        }
    }
}

extension RootNavigator {
    enum TargetState: Hashable {
        case reset
        case showPage
    }

    enum Path: Hashable {
        case page
    }
}
