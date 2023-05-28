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

struct SignalWrapper: Equatable {
    var identity: UUID
    var id: AnyHashable?
    var debugIdentifier: String?
    var value: Any?
    var signalResolved: @MainActor (_ id: AnyHashable?) -> Void

    public static func == (lhs: SignalWrapper, rhs: SignalWrapper) -> Bool {
        lhs.identity == rhs.identity
    }
}

private struct SignalWrapperKey: EnvironmentKey {
    static let defaultValue: SignalWrapper? = nil
}

extension EnvironmentValues {
    var signalWrapper: SignalWrapper? {
        get { self[SignalWrapperKey.self] }
        set { self[SignalWrapperKey.self] = newValue }
    }
}

// MARK: - Provider Extension

public extension View {

    /// Configures the provider to receive target states.
    ///
    /// - Parameter signal: The signal that sends the provider's target states.
    /// - Parameter id: An identifier to identify the target state's owner.
    /// - Returns: A view with a configured Signal reception.
    func sendSignals<Value>(
        _ signal: Signal<Value>.Wrapped,
        id: AnyHashable? = nil
    ) -> some View {
        return environment(
            \.signalWrapper,
                .init(
                    identity: signal.identity,
                    id: id,
                    debugIdentifier: signal.debugIdentifier,
                    value: signal.valueForId(id),
                    signalResolved: signal.removeValue
                )
        )
    }
}

struct SignalResolver<SignalValue>: ViewModifier {
    @Environment(\.signalWrapper) private var signalWrapper

    var action: (_ value: SignalValue) -> Void

    init(action: @escaping (_ value: SignalValue) -> Void) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .onFirstAppear {
                if let signalValue = signalWrapper?.value as? SignalValue {
                    action(signalValue)
                    logSignal(debugIdentifier: signalWrapper?.debugIdentifier, value: signalValue)
                    signalWrapper?.signalResolved(signalWrapper?.id)
                }
            }
            .onChange(of: signalWrapper) { newValue in
                guard let targetState = newValue?.value as? SignalValue else { return }
                action(targetState)
                signalWrapper?.signalResolved(newValue?.id)
            }
    }

    private func logSignal(debugIdentifier: String?, value: SignalValue) {
        logger.debug("Signal resolved: ».\(String(describing: value), privacy: .public)«")
    }
}

extension View {
    public func resolveSignals<SignalValue>(ofType signalValueType: SignalValue.Type, action: @escaping (_ value: SignalValue) -> Void) -> some View {
        modifier(SignalResolver(action: action))
    }
}
