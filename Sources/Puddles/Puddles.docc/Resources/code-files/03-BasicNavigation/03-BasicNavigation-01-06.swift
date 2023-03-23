import SwiftUI
import Puddles

struct RootNavigator: Navigator {
    @State private var isShowingSheet: Bool = false

    var root: some View {
        Root()
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
}

extension RootNavigator {
    enum TargetState: Hashable {
        case reset
        case showPage
    }
}
