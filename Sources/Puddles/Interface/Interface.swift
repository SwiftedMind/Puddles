import Combine
import SwiftUI
import AsyncAlgorithms

/// A wrapper around `ObservableObject` that provides an `actionPublisher` and a `sendAction(_:)` method that can be used as a unidirectional communication between views and coordinators.
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