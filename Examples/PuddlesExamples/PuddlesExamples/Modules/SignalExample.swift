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

struct SignalExample: View {
    @Environment(\.dismiss) private var dismiss
    @Signal<SubModule.Action> private var signal

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("I Demand An Answer!") {
                        signal.send(.showTheAnswer)
                    }
                } header: {
                    Text("Parent view")
                }

                Section {
                    SubModule()
                } header: {
                    Text("Nested view")
                }
            }
            .sendSignals(signal)
            .navigationTitle("Q&A")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SubModule: View {
    // This view has its own state, not a binding.
    // With signals you can give parent views controlled access to the state, without the parents having to own it themselves and pass it in.
    @State private var showMyPrivateLittleSecret: Bool = false

    var body: some View {
        content
            .animation(.default, value: showMyPrivateLittleSecret)
            .resolveSignals(ofType: Action.self) { action in
                switch action {
                case .showTheAnswer:
                    showMyPrivateLittleSecret = true
                }
            }
    }

    @ViewBuilder @MainActor
    private var content: some View {
        Text("Why did the bicycle fall over?")
        if showMyPrivateLittleSecret {
            Text("Because it was two-tired!")
        }
        Button("Toggle Visibility") {
            showMyPrivateLittleSecret.toggle()
        }
    }

}

extension SubModule {
    enum Action: Hashable {
        case showTheAnswer
    }
}

struct SignalExample_Previews: PreviewProvider {
    static var previews: some View {
        SignalExample()
            .withMockProviders()
    }
}

