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

import Combine
import SwiftUI

/// A property wrapper that lets you send one-time signals down the view hierarchy,
/// which is particularly useful for deep linking and state restoration without exposing all internal states of the child views.
///
/// To make a `View` receive and resolve Signals, use the `.resolveSignals(ofType:action:)` view modifier.
///
/// - Note: A resolved signal is consumed and will not travel further down the view hierarchy.
@propertyWrapper
public struct Signal<Value>: DynamicProperty {
    @StateObject private var stateHolder: SignalQueue<Value>

    public var wrappedValue: Wrapped {
        .init(
            identity: stateHolder.identity,
            debugIdentifier: stateHolder.debugIdentifier,
            valueForId: stateHolder.valueForId,
            onSend: stateHolder.send,
            removeValue: stateHolder.removeValue
        )
    }

    public init(
        initial value: Value? = nil,
        id: AnyHashable? = nil,
        debugIdentifier: String? = nil
    ) {
        _stateHolder = .init(wrappedValue: .init(initialValue: value, id: id, debugIdentifier: debugIdentifier))
    }
}

public extension Signal {
    struct Wrapped: Equatable {
        var identity: UUID
        var debugIdentifier: String?
        var valueForId: (_ id: AnyHashable?) -> Value?
        var onSend: @MainActor (_ value: Value, _ id: AnyHashable?) -> Void
        var removeValue: (_ id: AnyHashable?) -> Void

        /// Sends a target state.
        /// - Parameter value: The target state to send.
        @MainActor
        public func send(_ value: Value, id: AnyHashable? = nil) {
            onSend(value, id)
        }

        public static func == (lhs: Signal<Value>.Wrapped, rhs: Signal<Value>.Wrapped) -> Bool {
            lhs.identity == rhs.identity
        }
    }
}
