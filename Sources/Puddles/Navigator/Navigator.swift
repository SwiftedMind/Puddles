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

/// A type that coordinates the navigation of `Providers`.
public protocol Navigator: View {

    /// The type of the ``Puddles/Navigator/root`` view for a ``Puddles/Navigator``.
    ///
    /// This can be inferred by providing a `root` view.
    associatedtype RootView: View

    /// The type of the target state.
    ///
    /// This can be inferred by defining the ``Puddles/Navigator/applyTargetState(_:)`` method in a ``Puddles/Navigator``.
    associatedtype TargetState

    /// An identifier that can be used to name the `Provider`.
    ///
    /// This might be helpful while debugging.
    static var debugIdentifier: String { get }

    /// The entry point for the navigator, which is usually is a `NavigationStack`, `NavigationSplitView` or `TabView` with its `Providers`.
    @MainActor @ViewBuilder var root: RootView { get }

    /// Sets the state of the navigator according to the provided target state.
    ///
    /// This can be called manually but it is also automatically called, for example as a result of a ``Puddles/Navigator/handleDeepLink(_:)-6yc8o`` call.
    /// - Parameter state: The target state.
    @MainActor func applyTargetState(_ state: TargetState)

    /// Converts the provided deep link into a target state which is then automatically applied by calling ``Puddles/Navigator/applyTargetState(_:)``.
    ///
    /// - Important: You should only implement this method at the root navigator of your app and propagate any needed information to child views
    /// via ``Puddles/TargetStateSetter``.
    ///
    /// - Parameter deepLink: The incoming deep link
    /// - Returns: The target state to apply or `nil` if the deep link should not be handled.
    @MainActor func handleDeepLink(_ deepLink: URL) -> TargetState?

        /// A method that is called when the navigator has first appeared.
    ///
    /// The parent task is bound to the navigator's lifetime and is cancelled once it ends.
    /// Keep in mind, that it is up to the implementation to check for cancellations!
    ///
    /// - Important: This method is intentionally *not* called `onAppear()`.
    /// It does not behave like the `.onAppear(perform:)` view modifier,
    /// which can be called multiple times during the lifetime of the view.
    /// Instead, `start()` is only called exactly once, when the lifetime of the ``Puddles/Navigator`` starts.
    @MainActor func start() async

    /// A method that is called after the navigator has disappeared for the last and final time.
    ///
    /// More specifically, this method is called when SwiftUI deinitializes the `Navigator`'s data objects (think `@StateObject`), which,
    /// may occur some time *after* the final disappearance (due to optimizations by SwiftUI). It is, however, guaranteed to be called.
    /// Immediately before it is called, the `Task` that runs the ``Puddles/Provider/start()-9xt0v`` method is cancelled.
    ///
    ///- Important: This method is intentionally *not* called `onDisappear()`.
    /// It does not behave like the `.onDisappear(perform:)` view modifier,
    /// which can be called multiple times during the lifetime of the view.
    /// Instead, `stop()` is only called exactly once, when the lifetime of the ``Puddles/Navigator`` ends.
    @MainActor func stop()

}

public extension Navigator {

    @MainActor var body: some View {
        NavigatorBody<Self>(
            root: root,
            applyTargetStateHandler: applyTargetState,
            firstAppearHandler: {
                await start()
            },
            finalDisappearHandler: {
                stop()
            },
            deepLinkHandler: { url in
                handleDeepLink(url)
            }
        )
    }
}

public extension Navigator {

    @MainActor func handleDeepLink(_ deepLink: URL) -> TargetState? {
        return nil
    }

    static var debugIdentifier: String {
        "\(type(of: Self.self))"
    }

    @MainActor func start() async {}
    @MainActor func stop() {}
}

