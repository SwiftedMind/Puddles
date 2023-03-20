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
import Combine

public struct NavigatorBody<N: Navigator>: View {
    @Environment(\.signal) private var signal

    private let root: N.RootView

    private var deepLinkHandler: (_ url: URL) -> N.StateConfiguration?

    private let applyStateConfigurationHandler: (_ state: N.StateConfiguration) -> Void

    /// A closure reporting back first appearance of the view.
    private let firstAppearHandler: () async -> Void

    /// A closure reporting back the last disappearance of the view.
    private let finalDisappearHandler: () -> Void

    init(
        root: N.RootView,
        applyStateConfigurationHandler: @escaping (_ state: N.StateConfiguration) -> Void,
        firstAppearHandler: @escaping () async -> Void,
        finalDisappearHandler: @escaping () -> Void,
        deepLinkHandler: @escaping (_ url: URL) -> N.StateConfiguration?
    ) {
        self.root = root
        self.applyStateConfigurationHandler = applyStateConfigurationHandler
        self.firstAppearHandler = firstAppearHandler
        self.finalDisappearHandler = finalDisappearHandler
        self.deepLinkHandler = deepLinkHandler
    }

    public var body: some View {
        root
            .environment(\.signal, nil)
            .lifetimeHandlers {
                if let configuration = signal?.value as? N.StateConfiguration {
                    applyStateConfigurationHandler(configuration)
                    signal?.onSignalHandled()
                }
                await firstAppearHandler()
            } onFinalDisappear: {
                finalDisappearHandler()
            }
            .onOpenURL { url in
                logger.debug("Received deep link: »\(url, privacy: .public)«")
                guard let state = deepLinkHandler(url) else { return }
                applyStateConfigurationHandler(state)
            }
            .onChange(of: signal) { newValue in
                guard let configuration = newValue?.value as? N.StateConfiguration else { return }
                applyStateConfigurationHandler(configuration)
                signal?.onSignalHandled()
            }
    }
}

