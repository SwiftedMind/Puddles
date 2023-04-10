import SwiftUI
import Puddles

struct RootNavigator: Navigator {
    var entryView: some View {
        Root()
    }

    func applyTargetState(_ state: TargetState) {
        // Handle target states
    }
}

extension RootNavigator {
    enum TargetState: Hashable {
        case reset
        case showPage
    }
}
