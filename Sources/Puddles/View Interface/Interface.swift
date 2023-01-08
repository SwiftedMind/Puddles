import Combine
import SwiftUI

@MainActor
public final class Interface<Action>: ObservableObject {
	public let actionPublisher: PassthroughSubject<Action, Never> = .init()
	public init() {}

    @MainActor
    public func sendAction(_ action: Action) {
        actionPublisher.send(action)
    }
}

extension Interface {
    var actionStream: AsyncStream<Action> {
        AsyncStream<Action> { continuation in
            let canceller = actionPublisher
                .sink { newValue in
                    // https://forums.swift.org/t/pitch-2-structured-concurrency/43452/116
                    if Task.isCancelled {
                        continuation.finish()
                    } else {
                        continuation.yield(newValue)
                    }
                }

            continuation.onTermination = { continuation in
                canceller.cancel()
            }
        }
    }
}

extension PassthroughSubject where Failure == Never {
    var actionStream: AsyncStream<Output> {
        AsyncStream<Output> { continuation in
            let canceller = self
                .sink { newValue in
                    // https://forums.swift.org/t/pitch-2-structured-concurrency/43452/116
                    if Task.isCancelled {
                        continuation.finish()
                    } else {
                        continuation.yield(newValue)
                    }
                }

            continuation.onTermination = { continuation in
                canceller.cancel()
            }
        }
    }
}
