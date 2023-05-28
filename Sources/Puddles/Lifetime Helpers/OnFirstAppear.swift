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

/// An internal helper view that triggers the provided `action` closure exactly once on the first appearance of the view.
private struct ViewLifetimeHelper: ViewModifier {
    @StateObject private var lifetimeViewModel: LifetimeViewModel

    init(onInit: @MainActor @escaping () -> Void) {
        _lifetimeViewModel = .init(wrappedValue: .init(onInit: onInit))
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !lifetimeViewModel.hasAppeared else { return }
                lifetimeViewModel.onInit()
                lifetimeViewModel.hasAppeared = true
            }
    }
}

@MainActor
private final class LifetimeViewModel: ObservableObject {
    var hasAppeared: Bool = false
    let onInit: () -> Void

    init(onInit: @escaping () -> Void) {
        self.onInit = onInit
    }
}

extension View {
    @MainActor
    public func onFirstAppear(perform: @escaping () -> Void) -> some View {
        modifier(ViewLifetimeHelper(onInit: perform))
    }
}
