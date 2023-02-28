import SwiftUI
import Puddles

struct RootNavigator: Navigator {
    var root: some View {
        Root()
    }

    func applyStateConfiguration(_ configuration: StateConfiguration) {
        // Handle state configurations
    }
}

extension RootNavigator {
    enum StateConfiguration: Hashable {
        case reset
        case showPage
    }
}
