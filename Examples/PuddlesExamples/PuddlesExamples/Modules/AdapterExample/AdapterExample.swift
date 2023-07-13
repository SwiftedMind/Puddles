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

import Puddles
import SwiftUI

struct AdapterExample: View {
    @ObservedObject var adapter: ExampleAdapter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Button("Add Random Number Fact") {
                    adapter.fetchRandomFact()
                }
                Section {
                    Button("Sort") {
                        adapter.sort()
                    }
                    NumberFactStackView(numberFacts: adapter.facts, interface: .consume(handleViewInterface))
                } footer: {
                    Text("Data provided by [NumbersAPI.com](https://numbersapi.com)")
                }
            }
            .animation(.default, value: adapter.facts)
            .navigationTitle("Random Facts")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem {
                    Button("Remove All", role: .destructive) {
                        adapter.reset()
                    }
                }
            }
        }
    }

    @MainActor
    private func handleViewInterface(_ action: NumberFactStackView.Action) {
        switch action {
        case .deleteFacts(let indexSet):
            adapter.facts.remove(atOffsets: indexSet)
        }
    }
}

struct AdapterExample_Previews: PreviewProvider {
    static var previews: some View {
        AdapterExample(adapter: .init(numberFactProvider: .mock))
            .withMockProviders()
    }
}

