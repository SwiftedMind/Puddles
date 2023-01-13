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

struct QueryableDemo: Coordinator {
    @StateObject var viewInterface: Interface<QueryableDemoView.Action> = .init()

    @Queryable<Bool> private var deletionConfirmation

    var viewState: QueryableDemoView.ViewState {
        .init(

        )
    }

    var entryView: some View {
        QueryableDemoView(interface: viewInterface, state: viewState)
    }

    func navigation() -> some NavigationPattern {
        QueryControlled(by: deletionConfirmation) { isActive, query in
            Alert(
                title: "Do you want to delete this?",
                isPresented: isActive) {
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
    }

    func interfaces() -> some InterfaceObservation {
        InterfaceObserver(viewInterface) { action in
            handleViewAction(action)
        }
    }

    private func handleViewAction(_ action: QueryableDemoView.Action) {
        switch action {
        case .deleteButtonTapped:
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
    }

    private func delete() {
        print("Delete")
    }

}
