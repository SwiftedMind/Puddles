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

struct ExampleListView: View {

    var interface: Interface<Action>

    var body: some View {
        List {
            Section() {
                Button("Static Example") {
                    interface.send(.openStaticExample)
                }
                Button("Provider Example") {
                    interface.send(.openBasicProviderExample)
                }
                Button("Interaction Example") {
                    interface.send(.openViewInteractionExample)
                }
            } header: {
                Text("Basic")
            }
            Section() {
                Button("Adapters") {
                    interface.send(.openAdapterExample)
                }
                Button("Queryables") {
                    interface.send(.openQueryableExample)
                }
                Button("Signals") {
                    interface.send(.openSignalExample)
                }
            } header: {
                Text("Basic")
            }
        }
    }
}

extension ExampleListView {
    enum Action: Hashable {
        case openStaticExample
        case openBasicProviderExample
        case openViewInteractionExample
        case openAdapterExample
        case openQueryableExample
        case openSignalExample




    }
}

struct ExampleListViewe_Previews: PreviewProvider {
    static var previews: some View {
        ExampleListView(interface: .ignore)
    }
}

