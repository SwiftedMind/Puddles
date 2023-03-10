import SwiftUI
import Puddles

struct RootNavigator: Navigator {
    @State private var path: [Path] = []
    @Queryable<Bool> private var deletionConfirmation

    var root: some View {
        NavigationStack(path: $path) {
            Root(interface: .consume(handleRootAction))
                .navigationDestination(for: Path.self) { path in
                    destination(for: path)
                }
        }
        .queryableAlert(
            controlledBy: deletionConfirmation,
            title: "Do you want to delete this?"
        ) { query in
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
        case .showPage:
            path = [.page]
        case .showDeletionConfirmation:
            path = []
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
