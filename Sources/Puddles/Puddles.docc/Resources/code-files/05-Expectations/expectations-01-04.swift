import SwiftUI
import Puddles

struct MyCoordinator: Coordinator {
    @StateObject var interface: MyView.Interface = .init()

    @State private var isShowingConfirmationAlert: Bool = false

    var entryView: some View {
        MyView(interface: interface)
    }

    func navigation() -> some NavigationPattern {
        Alert(
            title: "Do you want to delete this?",
            isPresented: $isShowingConfirmationAlert) {
                Button("Cancel", role: .cancel) {
                    // Cancel
                }
                Button("OK") {
                    // Confirm
                }
            } message: {
                Text("This cannot be reversed!")
            }
    }

    func handleAction(_ action: Action) async {
        switch action {
        case .deleteButtonTapped:
            isShowingConfirmationAlert = true
        }
   }
}
