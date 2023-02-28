import SwiftUI
import Puddles

struct Root: Coordinator {
    @State var buttonTapCount: Int = 0

    var entryView: some View {
        HomeView(
            state: .init(
                buttonTapCount: buttonTapCount
            )
        )
    }
}
