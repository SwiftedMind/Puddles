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

@MainActor
public final class SignalQueue<SignalValue>: ObservableObject {
    private(set) var identity: UUID = .init()
    private var value: [AnyHashable?: SignalValue] = [:]
    let debugIdentifier: String?

    public init(
        initialValue: SignalValue? = nil,
        id: AnyHashable? = nil,
        debugIdentifier: String? = nil
    ) {
        self.value[id] = initialValue
        self.debugIdentifier = debugIdentifier

        if let initialValue {
            logSignal(value: initialValue, isInitial: true)
        }
    }

    func valueForId(_ id: AnyHashable?) -> SignalValue? {
        value[id]
    }

    public func send(_ value: SignalValue, id: AnyHashable? = nil) {
        logSignal(value: value, isInitial: false)
        self.value[id] = value
        objectWillChange.send()
        identity = .init()
    }

    func removeValue(id: AnyHashable?) {
        self.value.removeValue(forKey: id)
    }

    private func logSignal(value: SignalValue, isInitial: Bool) {
        let loggerPrefix = debugIdentifier == nil ? "" : debugIdentifier! + " - "
        let type = "\(isInitial ? "Initial" : "Sending")"
        logger.debug("\(loggerPrefix)\(type) Signal: ».\(String(describing: value), privacy: .public)«")
    }
}

// MARK: - Resolve Signals

struct SignalQueueResolver<SignalValue: Equatable>: ViewModifier {

    @ObservedObject private var signalQueue: SignalQueue<SignalValue>
    private var id: AnyHashable?
    var action: (_ value: SignalValue) -> Void

    init(
        signalQueue: SignalQueue<SignalValue>,
        id: AnyHashable?,
        action: @escaping (_ value: SignalValue) -> Void
    ) {
        self.signalQueue = signalQueue
        self.id = id
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .onFirstAppear {
                if let signalValue = signalQueue.valueForId(id) {
                    action(signalValue)
                    logSignal(debugIdentifier: signalQueue.debugIdentifier, value: signalValue)
                    signalQueue.removeValue(id: id)
                }
            }
            .onChange(of: signalQueue.valueForId(id)) { newValue in
                guard let targetState = newValue else { return }
                action(targetState)
                signalQueue.removeValue(id: id)
            }
    }

    private func logSignal(debugIdentifier: String?, value: SignalValue) {
        logger.debug("Signal resolved: ».\(String(describing: value), privacy: .public)«")
    }
}

extension View {
    public func resolveSignals<SignalValue: Equatable>(
        from signalQueue: SignalQueue<SignalValue>,
        withId id: AnyHashable? = nil,
        action: @escaping (_ value: SignalValue) -> Void
    ) -> some View {
        modifier(SignalQueueResolver(signalQueue: signalQueue, id: id, action: action))
    }
}
