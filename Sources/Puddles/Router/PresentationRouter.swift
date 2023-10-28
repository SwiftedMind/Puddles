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

import SwiftUI

public protocol PresentationRouter: BaseRouter {
	@MainActor func dismissPresentation()
	@MainActor func present(_ keyPath: ReferenceWritableKeyPath<Self, Bool>)
	@MainActor func present<Item: Identifiable>(_ keyPath: ReferenceWritableKeyPath<Self, Item?>, item: Item)
	@MainActor func dismiss(_ keyPath: ReferenceWritableKeyPath<Self, Bool>)
	@MainActor func dismiss<Item: Identifiable>(_ keyPath: ReferenceWritableKeyPath<Self, Item?>)
}

public extension PresentationRouter {
	@MainActor func present(_ keyPath: ReferenceWritableKeyPath<Self, Bool>) {
		dismissPresentation()
		self[keyPath: keyPath] = true
	}

	@MainActor func present<Item: Identifiable>(_ keyPath: ReferenceWritableKeyPath<Self, Item?>, item: Item) {
		dismissPresentation()
		self[keyPath: keyPath] = item
	}

	@MainActor func dismiss(_ keyPath: ReferenceWritableKeyPath<Self, Bool>) {
		self[keyPath: keyPath] = false
	}

	@MainActor func dismiss<Item: Identifiable>(_ keyPath: ReferenceWritableKeyPath<Self, Item?>) {
		self[keyPath: keyPath] = nil
	}
}
