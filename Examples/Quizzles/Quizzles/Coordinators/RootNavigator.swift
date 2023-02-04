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

import Puddles

enum RootNavigatorStateRestoration: Hashable {
    case reset
    case quizCreation(Quiz)
    case quizDetail(Quiz)
}

enum QuizDestination: Hashable {
    case detail(Quiz)
}

struct RootPresentation: NavigatorPresentation {
    @State var isShowing: Bool = false

    /// Queries a quiz creation starting with an empty draft quiz.
    @Queryable<Quiz> var emptyQuizCreation

    /// Queries a quiz creation while providing an initial draft quiz.
    ///
    /// For example, this is useful for deeplinking, when you want to have an initial state for the creation.
    /// You could also provide a wrapper containing other state values that `QuizCreationSheet` can initially set.
    @QueryableItem<Quiz, Quiz> var quizCreation

    /// Convenience method to reset all state.
    func reset() {
        isShowing = false
        emptyQuizCreation.cancel()
        quizCreation.cancel()
    }
}

struct RootNavigator: StackNavigator {
    @StateObject var listInterface: Interface<QuizList.Action> = .init()
    @State private var path: [QuizDestination] = []
    let presentationState: RootPresentation = .init()
    static var shouldHandleDeepLinks: Bool { true }

    var navigationPath: Binding<[QuizDestination]> { $path }

    var root: some Coordinator {
        QuizListProvider(
            listInterface: listInterface,
            quizCreation: presentationState.emptyQuizCreation
        )
    }

    func destination(for path: QuizDestination) -> some View {
        switch path {
        case .detail(let quiz):
            QuizDetail(quiz: .loaded(quiz))
        }
    }

    func interfaces() -> some InterfaceObservation {
        InterfaceObserver(listInterface) { action in
            switch action {
            case .quizTapped(let quiz):
                path = [.detail(quiz)]
            }
        }
    }

    func presentations() -> some NavigationPattern {
        Sheet(isActive: presentationState.$isShowing) {
            Text("ABC")
        }
        QueryItemControlled(by: presentationState.quizCreation) { item, query in
            SheetItem(item) { draftQuiz in
                QuizCreationSheet(draftQuiz: draftQuiz) { createdQuiz in
                    query.answer(withOptional: createdQuiz)
                }
            }
        }
        QueryControlled(by: presentationState.emptyQuizCreation) { isActive, query in
            Sheet(isActive: isActive) {
                QuizCreationSheet { createdQuiz in
                    query.answer(withOptional: createdQuiz)
                }
            }
        }
    }

    func restoreState(for state: RootNavigatorStateRestoration) async {
        switch state {
        case .reset:
            path.removeAll()
            presentationState.reset()
        case .quizCreation(let quiz):
            path.removeAll()
            guard let result = try? await presentationState.quizCreation.query(providing: quiz) else {
                return
            }
            path = [.detail(result)]
        case .quizDetail(let quiz):
            presentationState.reset()
            path = [.detail(quiz)]
        }
    }

    func handleDeepLink(_ deepLink: URL) async {
        if deepLink.absoluteString.contains("createQuiz") {
            await restoreState(for: .quizCreation(.mock))
        } else if deepLink.absoluteString.contains("Detail") {
            await restoreState(for: .quizDetail(.mock))
        } else {
            await restoreState(for: .reset)
        }
    }

}
