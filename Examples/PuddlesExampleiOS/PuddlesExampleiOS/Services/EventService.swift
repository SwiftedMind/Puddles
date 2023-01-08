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
import Puddles
import AsyncAlgorithms

public enum EventServiceAction {
    case eventSearchChanged(LoadingState<[Event], Swift.Error>)
}

public protocol EventService {
    @MainActor var interface: Interface<EventServiceAction> { get }
    @MainActor func start() async
    @Sendable func events() async throws -> [Event]
    @Sendable func submitSearchQuery(_ query: String) async
}

public final class MockEventService: EventService {

    @MainActor
    public let interface: Interface<EventServiceAction> = .init()

    private var events: [Event] = []
    private var channel: AsyncChannel<String> = .init()

    public init() {}

    @MainActor
    public func start() async {
        for await _ in channel.debounce(for: .seconds(0.5)) {
            if Task.isCancelled { return }
            interface.sendAction(.eventSearchChanged(.loading))
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            interface.sendAction(.eventSearchChanged(.loaded(.repeating(.random, count: 2))))
        }
    }

    @MainActor
    public func events() async throws -> [Event] {
        .repeating(.random, count: 10)
    }

    @MainActor
    public func submitSearchQuery(_ query: String) async {
        await channel.send(query)
    }
}

extension EventService where Self == MockEventService {
    public static var mock: EventService {
        MockEventService()
    }
}


