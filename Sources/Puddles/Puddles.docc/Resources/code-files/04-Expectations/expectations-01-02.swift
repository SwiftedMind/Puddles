import SwiftUI
import Puddles

struct QueryableDemo: Coordinator {
    @StateObject var viewInterface: Interface<QueryableDemoView.Action> = .init()

    var viewState: QueryableDemoView.ViewState {
        .init(

        )
    }

    var entryView: some View {
        QueryableDemoView(interface: viewInterface, state: viewState)
    }

    func navigation() -> some NavigationPattern {

    }

    func interfaces() -> some InterfaceObservation {
        InterfaceObserver(viewInterface) { action in
            handleViewAction(action)
        }
    }

    private func handleViewAction(_ action: QueryableDemoView.Action) {
        // Handle action
    }

}
