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

struct BasicProviderExample: View {
    @EnvironmentObject private var cultureMindsProvider: CultureMindsProvider
    @Environment(\.dismiss) private var dismiss

    // Modules can have and manage their own state, that's fine
    // This makes using SwiftUI much easier
    @State private var names: [String] = []
    @State private var namesTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            List {
                Text("The following list contain possible names for Minds in the \"Culture\" book series by Iain M. Banks. It has been generated by ChatGPT")
                Section {
                    CultureMindNameStackView(names: names)
                }
            }
            .navigationTitle("List of Culture Minds")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Restart") {
                        restart()
                    }
                }
            }
            .animation(.default, value: names)
        }
        .onFirstAppear(perform: restart)
        .onDisappear {
            namesTask?.cancel()
        }
    }

    private func restart() {
        names.removeAll()
        namesTask?.cancel()
        namesTask = Task {
            for await name in cultureMindsProvider.generateNames() {
                names.append(name)
            }
        }
    }
}

struct BasicProviderExample_Previews: PreviewProvider {
    static var previews: some View {
        BasicProviderExample()
            .withMockProviders()
    }
}

