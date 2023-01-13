import SwiftUI
import AsyncAlgorithms

public struct AsyncChannelObserver<Value>: InterfaceObservation {

    var channel: AsyncChannel<Value>
    var actionHandler: @MainActor (_ channel: AsyncChannel<Value>) async -> Void

    public init(
        _ channel: AsyncChannel<Value>,
        actionHandler: @MainActor @escaping (_ channel: AsyncChannel<Value>) async -> Void
    ) {
        self.channel = channel
        self.actionHandler = actionHandler
    }
}

public extension AsyncChannelObserver {

    @MainActor
    var body: some View {
        Color.clear
            .task {
                await actionHandler(channel)
            }
    }
}
