import SwiftUI
import Puddles

struct RootNavigator: Navigator {
    @State private var path: [Path] = []
    @State private var isShowingConfirmationAlert: Bool = false

    var entryView: some View {
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
                // Confirm
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

    func applyTargetState(_ state: TargetState) {
        switch state {
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
            applyTargetState(.showPage)
        case .didTapShowQueryableDemo:
            applyTargetState(.showDeletionConfirmation)
        }
    }
}

extension RootNavigator {
    enum TargetState: Hashable {
        case reset
        case showPage
        case showDeletionConfirmation
    }

    enum Path: Hashable {
        case page
    }
}
