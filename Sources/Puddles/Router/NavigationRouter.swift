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

/// A protocol defining helpful methods, including default implementations,
/// for navigation routers used with a `NavigationStack`.
public protocol NavigationRouter: ObservableObject {

    /// The destination type, which is usually an enum.
    associatedtype Destination: Hashable

    /// The path that is plugged into the `NavigationStack`.
    ///
    /// You should mark this property as `@Published` in your implementation.
    @MainActor var path: [Destination] { get set }

    /// Pushes the destination onto the current path.
    /// - Parameter destination: The destination to push.
    @MainActor func push(_ destination: Destination)

    /// Pops the last destination from the path.
    /// - Returns: The popped destination, or `nil` if the path was empty.
    @MainActor @discardableResult func pop() -> Destination?

    /// Removes all destinations from the path.
    @MainActor func popToRoot()

    /// Sets the current path to the given array of destination.s
    /// - Parameter stack: The destinations that will be set as the new path.
    @MainActor func setPath(_ stack: [Destination])
}

// MARK: - Default Implementations

public extension NavigationRouter {
    @MainActor func push(_ destination: Destination) {
        path.append(destination)
    }

    @MainActor @discardableResult func pop() -> Destination? {
        path.popLast()
    }

    @MainActor func popToRoot() {
        path.removeAll()
    }

    @MainActor func setPath(_ stack: [Destination]) {
        path = stack
    }
}
