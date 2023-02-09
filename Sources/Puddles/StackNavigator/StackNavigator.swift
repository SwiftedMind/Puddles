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

import Foundation

@available(iOS 16, macOS 13.0, *)
public protocol StackNavigator: View {

    associatedtype RootView: View

    associatedtype Path: Hashable

    associatedtype StateConfiguration

    associatedtype PathDestination: View

    @MainActor static var debugIdentifier: String { get }

    @MainActor @ViewBuilder var root: RootView { get }

    @MainActor var navigationPath: Binding<[Path]> { get }

    @MainActor @ViewBuilder func destination(for path: Path) -> PathDestination

    func applyStateConfiguration(_ configuration: StateConfiguration)

    func handleDeepLink(_ deepLink: URL) -> StateConfiguration?

        /// A method that is called when the navigator has first appeared.
    ///
    /// The parent task is bound to the navigator's lifetime and is cancelled once it ends.
    /// Keep in mind, that it is up to the implementation to check for cancellations!
    ///
    /// - Important: This method is intentionally *not* called `onAppear()`.
    /// It does not behave like the `.onAppear(perform:)` view modifier,
    /// which can be called multiple times during the lifetime of the view.
    /// Instead, `start()` is only called exactly once, when the lifetime of the ``Puddles/StackNavigator`` starts.
    func start() async

    /// A method that is called after the navigator has disappeared for the last and final time.
    ///
    /// More specifically, this method is called when SwiftUI deinitializes the `Navigator`'s data objects (think `@StateObject`), which,
    /// may occur some time *after* the final disappearance (due to optimizations by SwiftUI). It is, however, guaranteed to be called.
    /// Immediately before it is called, the `Task` that runs the ``Puddles/Coordinator/start()-7oqfy`` method is cancelled.
    ///
    ///- Important: This method is intentionally *not* called `onDisappear()`.
    /// It does not behave like the `.onDisappear(perform:)` view modifier,
    /// which can be called multiple times during the lifetime of the view.
    /// Instead, `stop()` is only called exactly once, when the lifetime of the ``Puddles/StackNavigator`` ends.
    func stop()

}

@available(iOS 16, macOS 13.0, *)
public extension StackNavigator {

    @MainActor var body: some View {
        StackNavigatorBody<Self>(
            root: root,
            destinationForPathHandler: { path in
                destination(for: path)
            },
            navigationPath: navigationPath
        ) { state in
            applyStateConfiguration(state)
        } firstAppearHandler: {
            await start()
        } finalDisappearHandler: {
            stop()
        } deepLinkHandler: { url in
            handleDeepLink(url)
        }
    }
}

@available(iOS 16, macOS 13.0, *)
public extension StackNavigator {

    @MainActor func handleDeepLink(_ deepLink: URL) -> StateConfiguration? {
        return nil
    }

    @MainActor static var debugIdentifier: String {
        "\(type(of: Self.self))"
    }

    func start() async {}
    func stop() {}
}

