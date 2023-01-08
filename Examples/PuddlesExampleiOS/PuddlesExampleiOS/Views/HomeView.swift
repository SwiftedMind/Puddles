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
    @ObservedObject var interface: Interface<Action>
    var state: ViewState
    
    var body: some View {
        content
            .searchable(text: Binding(get: {
                state.searchQuery
            }, set: { newValue in
                interface.sendAction(.searchQueryUpdated(newValue))
            }))
            .animation(.default, value: state.events)
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
                switch state.events {
                case .initial, .loading:
                    ProgressView()
                case .loaded(let points):
                    ForEach(points) { event in
                        Button(event.name) {
                            interface.sendAction(.eventTapped(event))
                        }
                    }
                }
                
            }
        }
        .listStyle(.insetGrouped)
    }
    
    @ViewBuilder private var searchContent: some View {
        Section {
            switch state.searchResults {
            case .initial, .loading:
                ProgressView()
            case .loaded(let points):
                List {
                    ForEach(points) { event in
                        Button(event.name) {
                            
                        }
                        
                    }
                    .listStyle(.insetGrouped)
                }
            }
        }
    }
}

extension HomeView {
    
    typealias EventsLoadingState = LoadingState<[Event], Never>
    typealias SearchResultsLoadingState = LoadingState<[Event], Never>
    
    struct ViewState {
        var events: EventsLoadingState = .initial
        var searchResults: SearchResultsLoadingState = .initial
        var searchQuery: String = ""
        
        static var mock: ViewState {
            .init(
                events: .loaded([.mock]),
                searchResults: .loaded([.random]),
                searchQuery: ""
            )
        }
    }
    
    enum Action {
        case eventTapped(Event)
        case searchQueryUpdated(String)
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Preview(HomeView.init, state: .mock) { action, state in
                switch action {
                case .eventTapped:
                    state.events = .loaded(state.events.value! + [.random])
                case .searchQueryUpdated(query: let query):
                    state.searchQuery = query
                }
            }
            .navigationTitle("Events")
        }
    }
}
