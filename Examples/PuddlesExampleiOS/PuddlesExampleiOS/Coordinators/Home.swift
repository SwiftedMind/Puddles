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

/*

 @Debounced private var searchDebouncer
 ...
 case .searchUpdated(let query):
    searchQuery = query
    try await searchDebouncer

 */

struct Home: Coordinator {
    @ObservedObject var interface: Interface<Action>
    @StateObject var viewInterface: HomeView.Interface = .init()

	let points: LoadingState<[Event], Never>
	let searchResults: LoadingState<[Event], Never>
    @State var sorting: Bool = true
	@State var searchQuery: String = ""

	var entryView: some View {
		HomeView(
			interface: viewInterface,
            state: .init(
                points: points,
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

/*
 How to do this:
 You need two separate things like a toggle and search query and combine them into a result (a search call). Also debounced. Difficult?
 -> Create action that contains both, like .filtersUpdated(query: String, someFilterValue: Bool). those are the combination and then debounce on this action
 -> Test this!
 */

    /* One app state? I dont know*/

    func interfaces() -> some InterfaceDescription {
        ActionObserver(viewInterface.eventTapped) { event in
            print("Event Tapped")
        }
        ActionObserver(viewInterface.searchQueryUpdated) { newValue in
            searchQuery = newValue
        }
        ActionStreamObserver(viewInterface.searchQueryUpdated) { stream in
            for await _ in stream.debounce(for: .seconds(2)) {
                print("Debounced Event Tapped")
            }
        }
//        AsyncInterfaceObserver(viewInterface) { action in
//            await handleViewAction(action)
//        }
//        InterfaceStreamObserver(viewSearchInterface) { stream in
//            // How to actually update the self.searchQuery string? That shouldn't be debouncedf
//            for await action in stream.debounce(for: .seconds(1)) {
//                print("print")
//            }
//        }
    }

//    func handleViewAction(_ action: HomeView.Action) async {
//        switch action {
//        case .eventTapped:
//            print("Event Tapped")
////        case .searchQueryUpdated(query: let query):
////            searchQuery = query
//        }
//    }

}

extension Home {

	enum Action {
		case searchEvents(query: String)
	}

}
