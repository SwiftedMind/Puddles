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

extension BookList {
    // A data provider for BookList. This one provides all of the user's favorite books
    struct Favorites: Provider {
        // A repository, service or manager can be used as an interface with a database or backend or anything else
        @EnvironmentObject private var favoriteBooksRepository: FavoriteBooksRepository

        // Relay for the BookList interface
        var interface: Interface<BookList.Action>

        // Here, the books live
        @State private var books: [Book] = []

        var entryView: some View {
            BookList(
                interface: .forward(to: interface), // Forward the interface
                books: books
            )
        }

        func start() async {
            do {
                // Fetch the books
                books = try await favoriteBooksRepository.fetchBooks()
            } catch {}
        }

        // MARK: - State Configurations

        @MainActor
        func applyTargetState(_ state: TargetState) {
            switch state {
            case .reset:
                books = []
            }
        }
    }
}

extension BookList.Favorites {
    enum TargetState {
        case reset
    }
}
