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
import Combine
import Puddles
//
//protocol MyProtocol {
//    associatedtype Content: View
//    @MainActor @ViewBuilder func content() -> Content
//}
//
//extension MyProtocol {
//    @MainActor @ViewBuilder func content() -> some View {
//        EmptyView()
//    }
//}
//
//struct Implementation: MyProtocol {
//    func content() -> Content {
//
//    }
//}

struct QuizDetail: Coordinator {
    static var debugIdentifier: String { "QuizDetail" }
    @StateObject var viewInterface: Interface<QuizDetailView.Action> = .init()


    @State private var isShowing: Bool = false

    let quiz: QuizDetailView.Quiz

    var entryView: some View {
        QuizDetailView(
            interface: viewInterface,
            state: .init(
                quiz: quiz
            )
        )
        .navigationTitle(quiz.value?.name ?? "No Name")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Open Sheet") {
                    isShowing = true
                }
            }
        }
    }

    func navigation() -> some NavigationPattern {
        Sheet(isActive: $isShowing) {
            TestCoordinator()
        }
    }

    func interfaces() -> some InterfaceObservation {
        InterfaceObserver(viewInterface) { action in

        }
    }
}

extension QuizDetail {
    enum Action {

    }
}
