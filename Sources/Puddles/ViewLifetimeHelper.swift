import SwiftUI

// TODO: Understand why SwiftUI Previews calls deinit in the view model immediately.

/// An internal helper view that triggers the provided `action` closure exactly once on the first appearance of the view.
struct ViewLifetimeHelper: View {
    @StateObject private var lifetimeViewModel: LifetimeViewModel

    init(
        cancelOnDeinit: Bool = true, // For use in previews, this should be false
        onInit: @escaping () async -> Void,
        onDeinit: @escaping () -> Void
    ) {
        _lifetimeViewModel = .init(
            wrappedValue: .init(
                cancelOnDeinit: cancelOnDeinit,
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

    private let cancelOnDeinit: Bool
    var onInit: () async -> Void
    var onDeinit: () -> Void

    @MainActor init(
        cancelOnDeinit: Bool,
        onInit: @escaping () async -> Void,
        onDeinit: @escaping () -> Void
    ) {
        self.cancelOnDeinit = cancelOnDeinit
        self.onInit = onInit
        self.onDeinit = onDeinit

        task = Task {
            await onInit()
        }
    }

    deinit {
        if cancelOnDeinit {
            task.cancel()
        }
        onDeinit()
    }

}
