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

// A Navigator is also just a SwiftUI view. It manages a navigational path.
struct BooksNavigator: Navigator {
    @StateObject private var favoriteBooksRepository: FavoriteBooksRepository = .init()

    // MARK: - Root

    @State private var path: [Path] = []

    var entryView: some View {
        NavigationStack(path: $path) {
            // Set the BookList as root, with the favorites Data Provider fetching the books
            BookList.Favorites(interface: .consume(handleBookListInterface))
                .navigationDestination(for: Path.self) { path in
                    destination(for: path)
                }
        }
        .environmentObject(favoriteBooksRepository)
    }

    // MARK: - State Configuration

    func applyTargetState(_ state: TargetState) {
        switch state {
        case .reset:
            path.removeAll()
        }
    }

    // MARK: - Destinations

    @ViewBuilder @MainActor
    private func destination(for path: Path) -> some View {
        switch path {
        case .bookDetail(let book):
            Text(book.name)
        }
    }


    // MARK: - Interface Handlers

    @MainActor
    private func handleBookListInterface(_ action: BookList.Action) {
        switch action {
        case .bookTapped(let book):
            path.append(.bookDetail(book))
        }
    }
}

extension BooksNavigator {
    enum TargetState: Hashable {
        case reset
    }

    enum Path: Hashable {
        case bookDetail(Book)
    }
}
