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

struct TabViewNavigatorBody<Navigator: TabViewNavigator>: View {
    @Environment(\.stateConfigurationId) private var stateConfigurationId

    private let tabViewContent: Navigator.TabViewContent

    private let selectionBinding: Binding<Navigator.TabSelection>

    private var deepLinkHandler: (_ url: URL) -> Navigator.StateConfiguration?

    private let applyStateConfigurationHandler: (_ state: Navigator.StateConfiguration) -> Void

    /// A closure reporting back first appearance of the view.
    private let firstAppearHandler: () async -> Void

    /// A closure reporting back the last disappearance of the view.
    private let finalDisappearHandler: () -> Void

    init(
        tabViewContent: Navigator.TabViewContent,
        selectionBinding: Binding<Navigator.TabSelection>,
        applyStateConfigurationHandler: @escaping (_ state: Navigator.StateConfiguration) -> Void,
        firstAppearHandler: @escaping () async -> Void,
        finalDisappearHandler: @escaping () -> Void,
        deepLinkHandler: @escaping (_ url: URL) -> Navigator.StateConfiguration?
    ) {
        self.tabViewContent = tabViewContent
        self.selectionBinding = selectionBinding
        self.applyStateConfigurationHandler = applyStateConfigurationHandler
        self.firstAppearHandler = firstAppearHandler
        self.finalDisappearHandler = finalDisappearHandler
        self.deepLinkHandler = deepLinkHandler
    }

    public var body: some View {
        // if tab hasn't opened yet, it will not receive a deeplink, unfortunately and cannot handle it initially. the tab view has to pass it down? how?
        //
        /*

a modifier on stacknavigator

         .signaling(_ configuration) internally uses a uuid to make identical, consecutive signals possible. this modifier makes a one time configuration application. its argzment is a state, which is a bit strange, though ,since states usually dont behave like signals

         */
        TabView(selection: selectionBinding) {
            tabViewContent
        }
        .background {
            ViewLifetimeHelper {
                if let state = stateConfigurations[stateConfigurationId] as? Navigator.StateConfiguration {
                    applyStateConfigurationHandler(state)
                }
                await firstAppearHandler()
            } onDeinit: {
                finalDisappearHandler()
            }
        }
        .onOpenURL { url in
            logger.debug("Received deep link: »\(url, privacy: .public)«")
            guard let state = deepLinkHandler(url) else { return }
            applyStateConfigurationHandler(state)
        }
    }
}

