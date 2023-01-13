import SwiftUI
import Puddles

struct QueryableDemo: Coordinator {
    @StateObject var viewInterface: Interface<QueryableDemoView.Action> = .init()

    @State private var isShowingConfirmationAlert: Bool = false

    var viewState: QueryableDemoView.ViewState {
        .init(

        )
    }

    var entryView: some View {
        QueryableDemoView(interface: viewInterface, state: viewState)
    }

    func navigation() -> some NavigationPattern {
        Alert(
            title: "Do you want to delete this?",
            isPresented: $isShowingConfirmationAlert) {
                Button("Cancel", role: .cancel) {
                    // Cancel
                }
                Button("OK") {
                    delete()
                }
            } message: {
                Text("This cannot be reversed!")
            }
    }

    func interfaces() -> some InterfaceObservation {
        InterfaceObserver(viewInterface) { action in
            handleViewAction(action)
        }
    }

    private func handleViewAction(_ action: QueryableDemoView.Action) {
        switch action {
        case .deleteButtonTapped:
            isShowingConfirmationAlert = true
        }
    }

    private func delete() {
        // Apply the deletion
    }

}
