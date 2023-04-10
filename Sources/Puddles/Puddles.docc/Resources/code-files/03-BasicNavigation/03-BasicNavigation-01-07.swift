import SwiftUI
import Puddles

struct RootNavigator: Navigator {
    @State private var isShowingSheet: Bool = false

    var entryView: some View {
        Root(interface: .consume(handleRootAction))
            .sheet(isPresented: $isShowingSheet) {
                Text("🎉")
                    .font(.largeTitle)
            }
    }

    func applyTargetState(_ state: TargetState) {
        switch state {
        case .reset:
            isShowingSheet = false
        case .showPage:
            isShowingSheet = true
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
}
