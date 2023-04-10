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

struct BookListView: View {

    var interface: Interface<Action> // Upstream communication
    var state: ViewState // Read-only state

    var body: some View {
        List {
            Button("Toggle Descriptions") {
                interface.fire(.showDescriptionsToggled)
            }
            ForEach(state.books) { book in
                Button {
                    interface.fire(.bookTapped(book))
                } label: {
                    VStack(alignment: .leading) {
                        Text(book.name)
                        if state.isShowingDescriptions {
                            Text(book.description)
                                .font(.caption)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

extension BookListView {
    struct ViewState {
        var books: [Book]
        var isShowingDescriptions: Bool

        static var mock: Self {
            .init(books: [.leviathanWakes, .calibansWar], isShowingDescriptions: true)
        }
    }

    enum Action {
        case showDescriptionsToggled
        case bookTapped(Book)
    }
}

struct BookListView_Previews: PreviewProvider {
    static var previews: some View {
        Preview(BookListView.init, state: .mock) { action, $state in
            switch action {
            case .showDescriptionsToggled:
                state.isShowingDescriptions.toggle()
            default:
                break
            }
        }
    }
}
