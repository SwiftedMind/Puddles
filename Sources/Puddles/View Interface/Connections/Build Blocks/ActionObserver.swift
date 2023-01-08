//
//  File.swift
//  
//
//  Created by Dennis Müller on 08.01.23.
//

import Combine
import SwiftUI

public struct ActionObserver<Value>: InterfaceDescription {

    var publisher: PassthroughSubject<Value, Never>
    var actionHandler: @MainActor (_ value: Value) -> Void

    public init(
        _ handle: Action<Value>.Handle,
        actionHandler: @MainActor @escaping (_ value: Value) -> Void
    ) {
        self.publisher = handle.publisher
        self.actionHandler = actionHandler
    }
}

public extension ActionObserver {

    @MainActor
    var body: some View {
        Color.clear
            .onReceive(publisher) { value in
                actionHandler(value)
            }
    }
}
