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
import Combine
import AsyncAlgorithms

struct Home: Coordinator {
    @ObservedObject var interface: Interface<Action>
    @StateObject var viewInterface: Interface<HomeView.Action> = .init()

    let events: HomeView.EventsLoadingState
    let searchResults: HomeView.SearchResultsLoadingState
    @State var sorting: Bool = true
	@State var searchQuery: String = ""

	var entryView: some View {
		HomeView(
			interface: viewInterface,
            state: .init(
                events: events,
                searchResults: searchResults,
                sorting: sorting,
                searchQuery: searchQuery
            )
		)
	}

    func modify(coordinator: CoordinatorContent) -> some View {
        NavigationView {
            coordinator
        }
    }

	func navigation() -> some NavigationPattern {

	}

    func interfaces() -> some InterfaceObservation {
        AsyncInterfaceObserver(viewInterface) { action in
            await handleViewAction(action)
        }
    }

    func handleViewAction(_ action: HomeView.Action) async {
        switch action {
        case .eventTapped:
            print("Event Tapped")
        case .searchQueryUpdated(query: let query):
            searchQuery = query
            // Pass through action to own interface.
            // The instance responsible for providing searchResults needs to decide on debouncing/throttling etc.
            interface.sendAction(.searchQueryUpdated(query))
        }
    }
}

extension Home {

	enum Action {
		case searchQueryUpdated(String)
	}

}
