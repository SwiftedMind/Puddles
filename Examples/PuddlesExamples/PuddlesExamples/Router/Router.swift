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

@MainActor final class Router: ObservableObject {
    static let shared: Router = .init()

    var home: HomeRouter = .init()

    enum Destination: Hashable {
        case root
        case staticExample
        case basicProviderExample
        case viewInteractionExample
        case adapterExample
        case queryableExample
        case signalExample
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .root:
            home.reset()
        case .staticExample:
            home.reset()
            home.isShowingStaticExample = true
        case .basicProviderExample:
            home.reset()
            home.isShowingBasicProviderExample = true
        case .viewInteractionExample:
            home.reset()
            home.isShowingViewInteractionExample = true
        case .adapterExample:
            home.reset()
            home.isShowingAdapterExample = true
        case .queryableExample:
            home.reset()
            home.isShowingQueryableExample = true
        case .signalExample:
            home.reset()
            home.isShowingSignalExample = true
        }
    }

    func navigateRoot(to destination: HomeRouter.Destination) {

    }
}
