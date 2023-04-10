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

public enum DeeplinkTarget: Hashable {
    case editScrum(Bool)
}

@MainActor
final class DeepLinkHandler: ObservableObject {
    static let shared: DeepLinkHandler = .init()

    var id: UUID = .init()
    var url: URL?

    init() {}

    static func resolve(for url: URL) -> DeeplinkTarget? {
        .editScrum(true)
    }
}

public struct NavigatorBody<N: Navigator>: View {
    @Environment(\.targetStateSetter) private var targetStateSetter
    @ObservedObject private var _deepLinkHandler: DeepLinkHandler = .shared

    @State private var handledId: UUID?

    private let root: N.EntryView

    private var deepLinkHandler: (_ url: URL) -> N.TargetState?

    private let applyTargetStateHandler: (_ state: N.TargetState) -> Void

    /// A closure reporting back first appearance of the view.
    private let firstAppearHandler: () async -> Void

    /// A closure reporting back the last disappearance of the view.
    private let finalDisappearHandler: () -> Void

    init(
        root: N.EntryView,
        applyTargetStateHandler: @escaping (_ state: N.TargetState) -> Void,
        firstAppearHandler: @escaping () async -> Void,
        finalDisappearHandler: @escaping () -> Void,
        deepLinkHandler: @escaping (_ url: URL) -> N.TargetState?
    ) {
        self.root = root
        self.applyTargetStateHandler = applyTargetStateHandler
        self.firstAppearHandler = firstAppearHandler
        self.finalDisappearHandler = finalDisappearHandler
        self.deepLinkHandler = deepLinkHandler
    }

    public var body: some View {
        root
            .lifetimeHandlers {
                if let targetState = targetStateSetter?.value as? N.TargetState {
                    applyTargetStateHandler(targetState)
                    targetStateSetter?.onTargetStateSet()
                }

                await firstAppearHandler()
            } onFinalDisappear: {
                finalDisappearHandler()
            }
            .onOpenURL { url in
                logger.debug("Received deep link: »\(url, privacy: .public)«")
                guard let state = deepLinkHandler(url) else { return }
                applyTargetStateHandler(state)
            }
            .onChange(of: targetStateSetter) { newValue in
                guard let targetState = newValue?.value as? N.TargetState else { return }
                applyTargetStateHandler(targetState)
                targetStateSetter?.onTargetStateSet()
            }
    }
}

