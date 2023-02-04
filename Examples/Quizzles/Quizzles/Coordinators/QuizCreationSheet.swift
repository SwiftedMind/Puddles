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

struct QuizCreationSheet: Coordinator {
    static var debugIdentifier: String { "QuizCreationSheet" }
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewInterface: Interface<QuizCreationView.Action> = .init()

    let onFinish: (_ createdQuiz: Quiz?) -> Void

    @State private var draftQuiz: Quiz

    init(
        draftQuiz: Quiz = .draft,
        onFinish: @escaping (_: Quiz?) -> Void
    ) {
        self._draftQuiz = .init(initialValue: draftQuiz)
        self.onFinish = onFinish
    }

    var viewState: QuizCreationView.ViewState {
        .init(
            quiz: draftQuiz
        )
    }

    func modify(coordinator: CoordinatorContent) -> some View {
        NavigationStack {
            coordinator
        }
        .interactiveDismissDisabled()
    }

    var entryView: some View {
        QuizCreationView(interface: viewInterface, state: viewState)
            .navigationTitle("New Quiz")
            .toolbar {
                toolbar
            }
    }

    func start() async {
    }

    func navigation() -> some NavigationPattern {

    }

    func interfaces() -> some InterfaceObservation {
        InterfaceObserver(viewInterface) { action in
            handleViewAction(action)
        }
    }

    private func handleViewAction(_ action: QuizCreationView.Action) {
        switch action {
        case .quizNameChanged(let newName):
            draftQuiz.name = newName
        case .quizItemQuestionChanged(let id, let newValue):
            draftQuiz.items[id: id]?.question = newValue
        case .quizItemAnswerChanged(let id, let newValue):
            draftQuiz.items[id: id]?.answer = newValue
        }
    }

    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarItem {
            Button("Cancel", role: .cancel) {
                onFinish(nil)
                dismiss()
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button("Save") {
                onFinish(draftQuiz)
                dismiss()
            }
            .bold()
        }
    }

    func handleDeepLink(_ deepLink: URL) {
        print("deeplink creation sheet")
        guard deepLink.absoluteString.contains("createQuiz") else {
            return
        }

        guard let items = URLComponents(string: deepLink.absoluteString)?.queryItems else {
            return
        }

        draftQuiz = .draft
        for item in items {

            if item.name == "name" {
                draftQuiz.name = item.value ?? ""
            }

            if item.name == "question" {
                let split = item.value!.split(separator: "-")
                draftQuiz.items.append(.init(question: String(split[0]), answer: String(split[1])))
            }
        }
    }
}
