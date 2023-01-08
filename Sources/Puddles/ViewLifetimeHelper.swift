import SwiftUI

/// An internal helper view that triggers the provided `action` closure exactly once on the first appearance of the view.
struct ViewLifetimeHelper: View {
    @StateObject private var lifetimeViewModel: LifetimeViewModel

    init(
        onInit: @escaping () async -> Void,
        onDeinit: @escaping () -> Void
    ) {
        _lifetimeViewModel = .init(
            wrappedValue: .init(
                onInit: onInit,
                onDeinit: onDeinit
            )
        )
    }

    var body: some View {
        Color.clear
    }
}

@MainActor private final class LifetimeViewModel: ObservableObject {

    private var task: Task<Void, Never>

    var onInit: () async -> Void
    var onDeinit: () -> Void

    @MainActor init(
        onInit: @escaping () async -> Void,
        onDeinit: @escaping () -> Void
    ) {
        self.onInit = onInit
        self.onDeinit = onDeinit

        task = Task {
            await onInit()
        }
    }

    deinit {
        task.cancel()
        onDeinit()
    }

}
