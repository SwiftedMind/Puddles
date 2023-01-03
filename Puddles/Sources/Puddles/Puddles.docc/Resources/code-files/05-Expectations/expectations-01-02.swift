import SwiftUI
import Puddles

struct MyCoordinator: Coordinator {
    @StateObject var interface: MyView.Interface = .init()

    var entryView: some View {
        MyView(interface: interface)
    }

    func navigation() -> some NavigationPattern {

    }

    func handleAction(_ action: Action) async {
        // Handle action
    }
}
