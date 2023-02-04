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

// sheet item? queryable?
// queryable dann im navigator? da sind ja die sheets. die triggern das in irgendeiner form?
// queryable im @Published?
@available(iOS 16.0, macOS 13.0, *)
public protocol NavigatorPresentation: DynamicProperty {
    init()
}

@available(iOS 16.0, macOS 13.0, *)
public struct EmptyNavigatorPresentation: NavigatorPresentation {
    public init() {

    }
}

@available(iOS 16, macOS 13.0, *)
public struct StackNavigatorBody<Navigator: StackNavigator>: View {
    @Environment(\.stateRestorationId) private var stateRestorationId

    private let root: Navigator.RootCoordinator

    private let presentations: Navigator.PresentationContent

    private let navigationPath: Binding<[Navigator.Path]>

    private let interfaces: Navigator.Interfaces

    private var destinationForPathHandler: (_ path: Navigator.Path) -> Navigator.PathDestination

    private var deepLinkHandler: (_ url: URL) async -> Void

    private let restoreStateHandler: (_ state: Navigator.StateRestoration) async -> Void

    /// A closure reporting back first appearance of the view.
    private let firstAppearHandler: () async -> Void

    /// A closure reporting back the last disappearance of the view.
    private let finalDisappearHandler: () -> Void

    init(
        root: Navigator.RootCoordinator,
        destinationForPathHandler: @escaping (_ path: Navigator.Path) -> Navigator.PathDestination,
        presentations: Navigator.PresentationContent,
        interfaces: Navigator.Interfaces,
        navigationPath: Binding<[Navigator.Path]>,
        restoreStateHandler: @escaping (_ state: Navigator.StateRestoration) async -> Void,
        firstAppearHandler: @escaping () async -> Void,
        finalDisappearHandler: @escaping () -> Void,
        deepLinkHandler: @escaping (_: URL) async -> Void
    ) {
        self.root = root
        self.destinationForPathHandler = destinationForPathHandler
        self.presentations = presentations
        self.interfaces = interfaces
        self.navigationPath = navigationPath
        self.restoreStateHandler = restoreStateHandler
        self.firstAppearHandler = firstAppearHandler
        self.finalDisappearHandler = finalDisappearHandler
        self.deepLinkHandler = deepLinkHandler
    }

    public var body: some View {
        NavigationStack(path: navigationPath) {
            root
                .navigationDestination(for: Navigator.Path.self, destination: { path in
                    destinationForPathHandler(path)
                })
        }
        .background(presentations)
        .background(interfaces)
        .background {
            ViewLifetimeHelper {

                if let state = stateRestorations[stateRestorationId] as? Navigator.StateRestoration {
                    await restoreStateHandler(state)
                }

                await firstAppearHandler()
            } onDeinit: {
                finalDisappearHandler()
            }
        }
        .onOpenURL { url in
            logger.debug("Received deep link: »\(url, privacy: .public)«")
            Task {
                await deepLinkHandler(url)
            }
        }
    }
}

