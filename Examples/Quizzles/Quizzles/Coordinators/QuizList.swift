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

struct QuizList: Coordinator {
    @StateObject var viewInterface: Interface<QuizListView.Action> = .init()

    @Queryable<Quiz> private var quizCreation
    let quizzes: QuizListView.Quizzes

    var viewState: QuizListView.ViewState {
        .init(
            quizzes: quizzes
        )
    }

    var entryView: some View {
        QuizListView(interface: viewInterface, state: viewState)
            .navigationTitle("Quizzes")
            .toolbar { toolbar }
    }

    func navigation() -> some NavigationPattern {
        QueryControlled(by: quizCreation) { isActive, query in
            Sheet(isActive: isActive) {
                QuizCreationSheet { createdQuiz in
                    query.answer(withOptional: createdQuiz)
                }
            }
        }
    }

    func interfaces() -> some InterfaceObservation {
        InterfaceObserver(viewInterface) { action in

        }
    }

    private func handleViewAction(_ action: QuizListView.Action) async {
        switch action {
        case .quizTapped:
            break
        }
    }

    func handleDeeplink(url: URL) -> DeepLinkPropagation {
        .shouldContinue
    }

    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                queryQuizCreation()
            } label: {
                Image(systemName: "plus")
            }
        }
    }

    private func queryQuizCreation() {
        Task {
            do {
                let quiz = try await quizCreation.query()
                print(quiz)
            } catch QueryError.queryCancelled {
            } catch {}
        }
    }
}
