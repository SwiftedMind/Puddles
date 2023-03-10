import SwiftUI
import Puddles

struct RootNavigator: Navigator {
    @State private var path: [Path] = []
    @State private var isShowingConfirmationAlert: Bool = false

    var root: some View {
        NavigationStack(path: $path) {
            Root(interface: .consume(handleRootAction))
                .navigationDestination(for: Path.self) { path in
                    destination(for: path)
                }
        }
        .alert(
            "Do you want to delete this?",
            isPresented: $isShowingConfirmationAlert
        ) {
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
    
    @MainActor @ViewBuilder
    func destination(for path: Path) -> some View {
        switch path {
        case .page:
            Text("🎉")
                .navigationTitle("It's the answer!")
        }
    }

    func applyStateConfiguration(_ configuration: StateConfiguration) {
        switch configuration {
        case .reset:
            path = []
            isShowingConfirmationAlert = false
        case .showPage:
            path = [.page]
            isShowingConfirmationAlert = false
        case .showDeletionConfirmation:
            path = []
            isShowingConfirmationAlert = true
        }
    }

    @MainActor
    private func handleRootAction(_ action: Root.Action) {
        switch action {
        case .didReachFortyTwo:
            applyStateConfiguration(.showPage)
        case .didTapShowQueryableDemo:
            applyStateConfiguration(.showDeletionConfirmation)
        }
    }

    private func delete() {
        // Perform deletion
    }
}

extension RootNavigator {
    enum StateConfiguration: Hashable {
        case reset
        case showPage
        case showDeletionConfirmation
    }

    enum Path: Hashable {
        case page
    }
}
