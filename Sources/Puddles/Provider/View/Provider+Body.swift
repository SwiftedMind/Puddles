import SwiftUI
import Combine

/// A helper view taking an `entryView` and configuring it for use as a ``Puddles/Provider``.
public struct ProviderBody<C: Provider>: View {
    @Environment(\.targetStateSetter) private var targetStateSetter

    /// The root view of the `Provider` as provided in ``Puddles/Provider/entryView-swift.property``.
    private let entryView: C.EntryView

    private let applyTargetStateHandler: (_ state: C.TargetState) -> Void

    /// A closure reporting back first appearance of the view.
    private let firstAppearHandler: () async -> Void

    /// A closure reporting back the last disappearance of the view.
    private let finalDisappearHandler: () -> Void

    /// A helper view taking an `entryView` and configuring it for use as a ``Puddles/Provider``.
    init(
        entryView: C.EntryView,
        applyTargetStateHandler: @escaping (_ state: C.TargetState) -> Void,
        firstAppearHandler: @escaping () async -> Void,
        finalDisappearHandler: @escaping () -> Void
    ) {
        self.entryView = entryView
        self.applyTargetStateHandler = applyTargetStateHandler
        self.firstAppearHandler = firstAppearHandler
        self.finalDisappearHandler = finalDisappearHandler
    }

    public var body: some View {
        ZStack { // To prevent the case of entryView being a Tuple. Then all the modifiers would be applied for every view in the tuple!
            entryView
        }
        .lifetimeHandlers {
            if let targetState = targetStateSetter?.value as? C.TargetState {
                applyTargetStateHandler(targetState)
                targetStateSetter?.onTargetStateSet()
            }
            await firstAppearHandler()
        } onFinalDisappear: {
            finalDisappearHandler()
        }
        .onChange(of: targetStateSetter) { newValue in
            guard let targetState = newValue?.value as? C.TargetState else { return }
            applyTargetStateHandler(targetState)
            targetStateSetter?.onTargetStateSet()
        }
    }
}

