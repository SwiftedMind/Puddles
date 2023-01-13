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

struct Root: Coordinator {
    @StateObject var viewInterface: Interface<HomeView.Action> = .init()
    @State var buttonTapCount: Int = 40

    @State private var isShowingPage: Bool = false
    @State private var isShowingQueryableDemo: Bool = false

    var viewState: HomeView.ViewState {
        .init(
            buttonTapCount: buttonTapCount
        )
    }

    var entryView: some View {
        HomeView(interface: viewInterface, state: viewState)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Queryable Demo") {
                        isShowingQueryableDemo = true
                    }
                }
            }
    }


    func modify(coordinator: CoordinatorContent) -> some View {
        NavigationStack {
            coordinator
        }
    }

    func navigation() -> some NavigationPattern {
        Push(isActive: $isShowingPage) {
            Text("🎉")
                .font(.largeTitle)
                .navigationTitle("Yay!")
        }
        Sheet(isActive: $isShowingQueryableDemo) {
            QueryableDemo()
        }
    }

    func interfaces() -> some InterfaceObservation {
        InterfaceObserver(viewInterface) { action in
            handleViewAction(action)
        }
    }

    private func handleViewAction(_ action: HomeView.Action) {
        switch action {
        case .buttonTaped:
            buttonTapCount += 1
            if buttonTapCount == 42 {
                isShowingPage = true
            }
        }
    }

}

