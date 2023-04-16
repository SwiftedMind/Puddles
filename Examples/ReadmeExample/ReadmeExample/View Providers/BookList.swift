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

// This is actually a SwiftUI view. It manages the BookListView's state.
struct BookList: Provider {

    // Interface to send actions to a parent
    var interface: Interface<Action>

    // External dependency passed in from parent, which usually is a Dependency Provider (but can be anything, really).
    // This makes this view provider highly reusable, since it does not know anything about the origin of the books
    var books: [Book]

    // View state lives here
    @State private var isShowingDescriptions: Bool = false

    // The entry view will be used to build the Provider's SwiftUI body
    var entryView: some View {
        BookListView(
            interface: .consume(handleViewInterface), // Handle the view's interface
            state: .init( // Create the view's state
                books: books,
                isShowingDescriptions: isShowingDescriptions
                        )
        )
    }

    // MARK: - Interface Handler

    // React to user interaction and update the view's state
    @MainActor
    private func handleViewInterface(_ action: BookListView.Action) {
        switch action {
        case .showDescriptionsToggled:
            isShowingDescriptions.toggle()
        case .bookTapped(let book):
            // Relay this tap so that a navigator upstream can handle navigation
            interface.fire(.bookTapped(book))
        }
    }

    // MARK: - State Configurations

    // Here, you can define target states that you want to access easily by calling applyTargetState(.someState)
    func applyTargetState(_ state: TargetState) {
        switch state {
        case .reset:
            isShowingDescriptions = false
        }
    }
}

extension BookList {

    enum TargetState {
        case reset
    }

    enum Action: Hashable {
        case bookTapped(Book)
    }
}
