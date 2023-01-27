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

@available(iOS 16, macOS 13.0, *)
public struct StackNavigatorBody<Navigator: StackNavigator>: View {

    @ObservedObject private var deepLinkStorage: DeepLinkStorage = .shared
    @State private var hasAppeared: Bool = false

    private let root: Navigator.Root
    private let destinationForPathHandler: (_ path: Navigator.Path) -> Navigator.PathDestination
    private let navigationPath: Binding<[Navigator.Path]>
    private var deepLinkHandler: (_ url: URL) async -> Void
    private var initialPathHandler: (_ url: URL) -> [Navigator.Path]?

    init(
        root: Navigator.Root,
        destinationForPathHandler: @escaping (_ path: Navigator.Path) -> Navigator.PathDestination,
        navigationPath: Binding<[Navigator.Path]>,
        deepLinkHandler: @escaping (_: URL) async -> Void,
        initialPathHandler: @escaping (_ url: URL) -> [Navigator.Path]?
    ) {
        self.root = root
        self.destinationForPathHandler = destinationForPathHandler
        self.navigationPath = navigationPath
        self.deepLinkHandler = deepLinkHandler
        self.initialPathHandler = initialPathHandler
    }

    public var body: some View {
        ZStack {
            NavigationStack(path: navigationPath, root: {
                root
                    .navigationDestination(for: Navigator.Path.self, destination: { path in
                        destinationForPathHandler(path)
                    })
            })
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            if let url = deepLinkStorage.url, let path = initialPathHandler(url) {
                navigationPath.wrappedValue = path
            }
        }
        .onOpenURL { url in
            logger.debug("Received deep link: »\(url, privacy: .public)«")
            Task {
                await deepLinkHandler(url)
                DeepLinkStorage.shared.url = url
            }
        }
    }
}

