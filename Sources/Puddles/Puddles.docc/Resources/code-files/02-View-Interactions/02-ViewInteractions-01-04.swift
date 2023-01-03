import SwiftUI
import Puddles

struct Root: Coordinator {
    @StateObject var interface: HomeView.Interface = .init()

    var entryView: some View {
        HomeView(interface: interface)
    }

    func navigation() -> some NavigationPattern {
        // Empty for now
    }

}
