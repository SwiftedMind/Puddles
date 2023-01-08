//
//  File.swift
//  
//
//  Created by Dennis Müller on 08.01.23.
//

import Combine
import SwiftUI

public struct ActionStreamObserver<Value>: InterfaceDescription {

    var publisher: PassthroughSubject<Value, Never>
    var actionHandler: @Sendable (_ stream: AsyncStream<Value>) async -> Void

    public init(
        _ handle: Action<Value>.Handle,
        actionHandler: @Sendable @escaping (_ stream: AsyncStream<Value>) async -> Void
    ) {
        self.publisher = handle.publisher
        self.actionHandler = actionHandler
    }
}

public extension ActionStreamObserver {

    @MainActor
    var body: some View {
        Color.clear
            .task {
                await actionHandler(publisher.actionStream)
            }
    }
}
