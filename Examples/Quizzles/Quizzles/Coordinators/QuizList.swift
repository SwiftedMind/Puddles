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

@MainActor class QuizListModel: ObservableObject {

    @Published var quizzes: QuizListView.Quizzes

    init(quizzes: QuizListView.Quizzes) {
        self.quizzes = quizzes
    }

    func applyDeepLink(url: URL) {

    }
}

struct Test {
    var test: String

    init() {
        self.test = ""
    }
}

struct QuizList: Coordinator {
    static var debugIdentifier: String { "QuizList" }
    @StateObject var viewInterface: Interface<QuizListView.Action> = .init()

    @State private var creationTask: Task<Void, Never>?

    @ObservedObject var interface: Interface<Action>
    let quizzes: QuizListView.Quizzes

    // IDEA: quiz search with mock network search for quizzes, Filter UI, deletion, sorting, duplicate quiz, templates, "play quiz" flow
    let quizCreation: Queryable<Quiz>.Trigger

    var entryView: some View {
        QuizListView(
            interface: viewInterface,
            state: .init(
                quizzes: quizzes
            )
        )
        .navigationTitle("Quizzes")
        .toolbar { toolbar }
    }

    func navigation() -> some NavigationPattern {
    }

    func interfaces() -> some InterfaceObservation {
        InterfaceObserver(viewInterface) { action in
            handleViewAction(action)
        }
    }

    private func handleViewAction(_ action: QuizListView.Action) {
        switch action {
        case .quizTapped(let quiz):
            interface.sendAction(.quizTapped(quiz))
        }
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
        creationTask?.cancel()
        creationTask = Task {
            do {
                let quiz = try await quizCreation.query()
                print(quiz)
            } catch QueryCancellationError() {
            } catch {}
        }
    }
}

extension QuizList {
    enum Action {
        case quizTapped(Quiz)
    }
}
