//
//  Copyright © 2023 Dennis Müller and all collaborators
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

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

    // MARK: - Interface Handlers

    @MainActor
    private func handleRootAction(_ action: Root.Action) {
        switch action {
        case .didReachFortyTwo:
            applyTargetState(.showPage)
        case .didTapShowQueryableDemo:
            applyTargetState(.showDeletionConfirmation)
        }
    }

    // MARK: - Configurations

    func applyTargetState(_ state: TargetState) {
        switch state {
        case .reset:
            deletionConfirmation.cancel()
            path = []
        case .showPage:
            deletionConfirmation.cancel()
            path = [.page]
        case .showDeletionConfirmation:
            path = []
            queryDeletion()
        }
    }

    private func queryDeletion() {
        Task {
            do {
                if try await deletionConfirmation.query() {
                    delete()
                }
            } catch {
                // Error Handling
            }
        }
    }

    private func delete() {
        print("Delete")
    }

    func handleDeepLink(_ deepLink: URL) -> TargetState? {
        nil
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
