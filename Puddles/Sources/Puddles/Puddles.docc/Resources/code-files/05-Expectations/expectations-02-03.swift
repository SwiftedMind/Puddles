import SwiftUI
import Puddles

struct MyCoordinator: Coordinator {
    @StateObject var interface: MyView.Interface = .init()

    @State private var deletionConfirmation = Expectation<Bool>.guaranteedCompletion()

    var entryView: some View {
        MyView(interface: interface)
    }

    func navigation() -> some NavigationPattern {
        Expecting($deletionConfirmation) { isActive, expectation in
            Alert(
                title: "Do you want to delete this?",
                isPresented: isActive) {
                    Button("Cancel", role: .cancel) {
                        expectation.complete(with: false)
                    }
                    Button("OK") {
                        expectation.complete(with: true)
                    }
                } message: {
                    Text("This cannot be reversed!")
                }
        }
    }

    func handleAction(_ action: Action) async {
        switch action {
        case .deleteButtonTapped:
            isShowingConfirmationAlert = true
        }
    }

    private func delete() {
        // Apply the deletion
    }
}
