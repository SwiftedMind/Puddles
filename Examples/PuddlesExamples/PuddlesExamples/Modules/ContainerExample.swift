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
import Models

@MainActor
struct ContainerExample: View {
    @Environment(\.dismiss) private var dismiss
    
    /// A "container" that accesses the NumberFactProvider from the current
    /// environment and provides additional states and methods to store and
    /// sort number facts.
    ///
    /// This logic could be place inside this view, but extracting it makes it reusable, while still staying fully mockable (since it can access
    /// the environment itself. We don't have to pass it in.)
    var numberFacts = SortableNumberFacts()

    var body: some View {
        NavigationStack {
            List {
                Button("Add Random Number Fact") {
                    numberFacts.fetchRandomFact()
                }
                Section {
                    Button("Sort") {
                        numberFacts.sort()
                    }
                    NumberFactStackView(numberFacts: numberFacts.facts, interface: .consume(handleViewInterface))
                } footer: {
                    Text("Data provided by [NumbersAPI.com](https://numbersapi.com)")
                }
            }
            .animation(.default, value: numberFacts.facts)
            .navigationTitle("Random Facts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem {
                    Button("Remove All", role: .destructive) {
                        numberFacts.reset()
                    }
                }
            }
        }
    }

    @MainActor
    private func handleViewInterface(_ action: NumberFactStackView.Action) {
        switch action {
        case .deleteFacts(let indexSet):
            numberFacts.facts.remove(atOffsets: indexSet)
        }
    }
}

struct ContainerExample_Previews: PreviewProvider {
    static var previews: some View {
        ContainerExample()
            .withMockProviders()
    }
}

