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
    @State private var isShowingQueryableDemo: Bool = false

    var root: some View {
        NavigationStack(path: $path) {
            Root(interface: .handled(by: handleRootAction))
                .navigationDestination(for: Path.self) { path in
                    destination(for: path)
                }
        }
        .sheet(isPresented: $isShowingQueryableDemo) {
            QueryableDemo()
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
            applyStateConfiguration(.showPage)
        case .didTapShowQueryableDemo:
            applyStateConfiguration(.showQueryableDemo)
        }
    }

    // MARK: - Configurations

    func applyStateConfiguration(_ configuration: StateConfiguration) {
        switch configuration {
        case .showPage:
            isShowingQueryableDemo = false
            path = [.page]
        case .showQueryableDemo:
            isShowingQueryableDemo = true
        }
    }

    func handleDeepLink(_ deepLink: URL) -> StateConfiguration? {
        nil
    }
}

extension RootNavigator {

    enum StateConfiguration: Hashable {
        case showQueryableDemo
        case showPage
    }

    enum Path: Hashable {
        case page
    }
}
