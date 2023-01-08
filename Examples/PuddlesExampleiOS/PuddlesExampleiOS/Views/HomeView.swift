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

struct HomeView: View {
    @ObservedObject var interface: Interface
    var state: ViewState

	var body: some View {
        content
            .searchable(text: Binding(get: {
                state.searchQuery
            }, set: { newValue in
                interface.searchQueryUpdated.send(newValue)
//                searchInterface.sendAction(.queryUpdated(query: newValue))
            }))
            .animation(.default, value: state.points)
            .animation(.default, value: state.searchResults)
    }

    @ViewBuilder private var content: some View {
        if state.searchQuery.isEmpty {
            eventsContent
        } else {
            searchContent
        }
    }

    @ViewBuilder private var eventsContent: some View {
        List {
            Text("List:")
            Section {
                switch state.points {
                case .initial, .loading:
                    ProgressView()
                case .loaded(let points):
                    ForEach(points) { event in
                        Button(event.name) {
                            interface.eventTapped.send(event)
                        }

                    }
                }

            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder private var searchContent: some View {
        List {
            Text("List:")
            Section {
                switch state.searchResults {
                case .initial, .loading:
                    ProgressView()
                case .loaded(let points):
                    ForEach(points) { event in
                        Button(event.name) {
                            interface.general.send(.a(.mock))
                        }
                    }
                }

            }
        }
        .listStyle(.insetGrouped)
    }
}

extension HomeView {

    @MainActor final class Interface: ObservableObject {
        @Action<Event> var eventTapped
        @Action<String> var searchQueryUpdated
        @Action<Test> var general
    }

    enum Test {
        case a(Event)
    }

    struct ViewState {
        var points: LoadingState<[Event], Never> = .initial
        var searchResults: LoadingState<[Event], Never> = .initial
        var sorting: Bool = true
        var searchQuery: String = ""

        static var mock: ViewState {
            .init(
                points: .loaded([.mock]),
                searchResults: .loaded([.random]),
                sorting: true,
                searchQuery: ""
            )
        }
    }

//	enum Action {
//        case eventTapped(Event)
//	}

}

//struct HomeView_Previews: PreviewProvider {
//	static var previews: some View {
//        NavigationView {
//            Preview(HomeView.init, state: .mock) { action, state in
//                switch action {
//                case .eventTapped:
//                    state.points = .loaded(state.points.value! + [.random])
////                case .searchQueryUpdated(query: let query):
////                    // Debouncing, how?
////                    state.searchQuery = query
//                }
//            }
//            .navigationTitle("Events")
//        }
//    }
//}
