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

struct QuizCreationView: View {
    @ObservedObject var interface: Interface<Action>

    let state: ViewState

    @State private var name: String = ""
    private var nameBinding: Binding<String> {
        .init {
            state.quiz.name
        } set: { newValue in
//            name = newValue
            interface.sendAction(.quizNameChanged(newName: newValue))
        }
    }

    var body: some View {
        Form {
            TextField("Quiz Name", text: nameBinding)
        }
    }
}

extension QuizCreationView {
    struct ViewState {
        var quiz: Quiz

        static var mock: ViewState {
            .init(quiz: .mock)
        }
    }

    enum Action {
        case quizNameChanged(newName: String)
    }
}

struct QuizCreationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Preview(QuizCreationView.init, state: .mock) { action, $state in
                switch action {
                case .quizNameChanged(let newName):
                    break
                }
            }
            .navigationTitle("Quizzes")
        }
    }
}
