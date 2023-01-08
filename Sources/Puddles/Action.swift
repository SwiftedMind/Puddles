//
//  File.swift
//  
//
//  Created by Dennis Müller on 08.01.23.
//

import SwiftUI
import Combine

public protocol ActionSender: AnyObject {
    associatedtype Value
    @MainActor func send(_ value: Value)
}

public extension ActionSender where Value == Void {
    @MainActor func send() {
        send(())
    }
}

@propertyWrapper public struct Action<Value> {

    private var storage: Storage = .init()

    public var wrappedValue: Handle {
        Handle(publisher: storage.publisher)
    }

    public init() {}
}

public extension Action {

    // TODO: Custom Publisher that emits warning when an Action is published without someone having subscribed to it.n
    final class Storage: ObservableObject {
        var publisher: PassthroughSubject<Value, Never> = .init()
        init() {}
    }

    struct Handle {
        var publisher: PassthroughSubject<Value, Never>

        @MainActor
        public func send(_ value: Value) {
            publisher.send(value)
        }

        @MainActor
        func send() where Value == Void {
            send(())
        }
    }
}

public typealias EmptyAction = Action<Void>
