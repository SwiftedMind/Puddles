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
import PreviewDebugTools
import Combine

struct QuizListView: View {
    @ObservedObject var interface: Interface<Action>
    let state: ViewState

    var body: some View {
        List {
            switch state.quizzes {
            case .initial, .loading:
                LoadingView()
            case .failure:
                Text("Fehler")
            case .loaded(let quizzes):
                loadedContent(quizzes: quizzes)
            }
        }
        .animation(.default, value: state.quizzes)
    }

    @ViewBuilder private func loadedContent(quizzes: [Quiz]) -> some View {
        ForEach(quizzes) { quiz in
            Button(quiz.name) {
                interface.sendAction(.quizTapped(quiz))
            }
        }
    }
}

extension QuizListView {

    typealias Quizzes = LoadingState<[Quiz], Swift.Error>

    struct ViewState {
        var quizzes: Quizzes

        static var mock: ViewState {
            .init(quizzes: .loaded(.repeating(.mock, count: 5)))
        }
    }

    enum Action {
        case quizTapped(Quiz)
    }
}

struct QuizListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Preview(QuizListView.init, state: .mock) { action, state in

            }
            .overlay(alignment: .bottom) { $state in
                HStack {
                    DebugButton("Loading") {
                        state.quizzes = .loading
                    }
                    .disabled(state.quizzes.isLoading)
                    DebugButton("Error") {
                        state.quizzes = .failure(.debug)
                    }
                    .disabled(state.quizzes.isFailure)
                    DebugButton("Success") {
                        state.quizzes = .loaded(.repeating(.mock, count: 5))
                    }
                    .disabled(state.quizzes.isLoaded)
                }
            }
            .navigationTitle("Quizzes")
        }
    }
}
