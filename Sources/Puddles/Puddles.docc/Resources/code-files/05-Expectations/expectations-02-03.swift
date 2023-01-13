import SwiftUI
import Puddles

struct QueryableDemo: Coordinator {
    @StateObject var viewInterface: Interface<QueryableDemoView.Action> = .init()

    @Queryable<Bool> private var deletionConfirmation

    var viewState: QueryableDemoView.ViewState {
        .init(

        )
    }

    var entryView: some View {
        QueryableDemoView(interface: viewInterface, state: viewState)
    }

    func navigation() -> some NavigationPattern {
        QueryControlled(by: deletionConfirmation) { isActive, query in
            Alert(
                title: "Do you want to delete this?",
                isPresented: isActive
            ) {
                Button("Cancel", role: .cancel) {
                    query.answer(with: false)
                }
                Button("OK") {
                    query.answer(with: true)
                }
            } message: {
                Text("This cannot be reversed!")
            }
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
