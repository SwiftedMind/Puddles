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
import IdentifiedCollections
import Queryable
import Models

struct Home: View {
    @EnvironmentObject private var numberFactProvider: NumberFactProvider
    @ObservedObject private var homeRouter = Router.shared.home

    var body: some View {
        NavigationStack(path: $homeRouter.path) {
            List {
                SimpleExamplesSection(interface: .consume(handleSimpleExamplesInterface))
                AdvancedExamplesSection(interface: .consume(handleAdvancedExamplesInterface))
            }
            .navigationTitle("Home")
        }
        .fullScreenCover(isPresented: $homeRouter.isShowingStaticExample) {
            StaticExample()
        }
        .fullScreenCover(isPresented: $homeRouter.isShowingBasicProviderExample) {
            BasicProviderExample()
        }
        .fullScreenCover(isPresented: $homeRouter.isShowingAdapterExample) {
            StateObjectHosting {
                // Will be initialized as `@StateObject` inside `StateObjectHosting` and passed to the content closure
                ExampleAdapter(numberFactProvider: numberFactProvider)
            } content: { adapter in
                AdapterExample(adapter: adapter)
            }
        }
        .fullScreenCover(isPresented: $homeRouter.isShowingQueryableExample) {
            QueryableExample()
        }
        .fullScreenCover(isPresented: $homeRouter.isShowingSignalExample) {
            SignalExample()
        }
    }

    @MainActor
    private func handleSimpleExamplesInterface(_ action: SimpleExamplesSection.Action) {
        switch action {
        case .openStaticExample:
            Router.shared.navigate(to: .staticExample)
        case .openBasicProviderExample:
            Router.shared.navigate(to: .basicProviderExample)
        }
    }

    @MainActor
    private func handleAdvancedExamplesInterface(_ action: AdvancedExamplesSection.Action) {
        switch action {
        case .openAdapterExample:
            Router.shared.navigate(to: .adapterExample)
        case .openQueryableExample:
            Router.shared.navigate(to: .queryableExample)
        case .openSignalExample:
            Router.shared.navigate(to: .signalExample)
        }
    }
}

struct HomeHome_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .withMockProviders()
    }
}
