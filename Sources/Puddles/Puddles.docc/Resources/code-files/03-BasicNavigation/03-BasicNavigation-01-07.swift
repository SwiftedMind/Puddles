import SwiftUI
import Puddles

struct RootNavigator: Navigator {
    @State private var isShowingSheet: Bool = false

    var root: some View {
        Root(interface: .handled(by: handleRootAction))
            .sheet(isPresented: $isShowingSheet) {
                Text("🎉")
                    .font(.largeTitle)
            }
    }

    func applyStateConfiguration(_ configuration: StateConfiguration) {
        switch configuration {
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
            applyStateConfiguration(.showPage)
        }
    }
}

extension RootNavigator {
    enum StateConfiguration: Hashable {
        case reset
        case showPage
    }
}
