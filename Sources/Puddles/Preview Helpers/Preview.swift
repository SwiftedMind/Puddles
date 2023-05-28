import SwiftUI

/// A SwiftUI previews helper type allowing to take advantage of view interfacing by providing an in-place mechanism of reacting to the view's actions.
///
/// - Important: This is only meant to be used within previews!
///
/// For more details on the view interfacing concept, see `Interface`.
public struct Preview<Action, PreviewState, Content: View, Overlay: View>: View {
    @State var state: PreviewState

    var content: (_ interface: Interface<Action>, _ state: PreviewState) -> Content
    var actionHandler: (_ action: Action, _ state: Binding<PreviewState>) -> Void
    var onStart: ((_ state: Binding<PreviewState>) async -> Void)?

    var maximizedPreviewFrame: Bool = false

    var overlayAlignment: Alignment = .bottom
    var debugOverlay: (_ state: Binding<PreviewState>) -> Overlay

    /// A SwiftUI previews helper type allowing to take advantage of view interfacing by providing an in-place mechanism of reacting to the view's actions.
    ///
    /// - Important: This is only meant to be used within previews!
    public init(
        state: @autoclosure @escaping () -> PreviewState,
        interfaceAction: Action.Type,
        @ViewBuilder _ content: @escaping (_ interface: Interface<Action>, _ state: PreviewState) -> Content,
        actionHandler: @escaping (_ action: Action, _ state: Binding<PreviewState>) -> Void
    ) where Overlay == EmptyView {
        self._state = .init(wrappedValue: state())
        self.content = { content($0, $1) }
        self.actionHandler = actionHandler
        self.debugOverlay = {_ in EmptyView() }
    }

    private init(
        @ViewBuilder _ content: @escaping (_ interface: Interface<Action>, _ state: PreviewState) -> Content,
        @ViewBuilder debugOverlay: @escaping (_ state: Binding<PreviewState>) -> Overlay,
        overlayAlignment: Alignment,
        state: @autoclosure () -> PreviewState,
        maximizedPreviewFrame: Bool,
        onStart: ((_ state: Binding<PreviewState>) async -> Void)?,
        actionHandler: @escaping (_ action: Action, _ state: Binding<PreviewState>) -> Void
    ) {
        self._state = .init(wrappedValue: state())
        self.content = content
        self.maximizedPreviewFrame = maximizedPreviewFrame
        self.actionHandler = actionHandler
        self.debugOverlay = debugOverlay
        self.overlayAlignment = overlayAlignment
        self.onStart = onStart
    }
    
    public var body: some View {
        content(.consume { actionHandler($0, $state) }, state)
            .frame(
                maxWidth: maximizedPreviewFrame ? .infinity : nil,
                maxHeight: maximizedPreviewFrame ? .infinity : nil
            )
            .overlay(alignment: overlayAlignment) {
                debugOverlay($state)
            }
            .task {
                await onStart?($state)
            }
    }

    public func fullScreenPreview() -> Preview {
        var copy = self
        copy.maximizedPreviewFrame = true
        return copy
    }
    
    public func onStart(perform: @escaping (_ state: Binding<PreviewState>) async -> Void) -> Preview {
        var copy = self
        copy.onStart = perform
        return copy
    }

    public func overlay<OverlayContent: View>(
        alignment: Alignment = .bottom,
        maximizedPreviewFrame: Bool = true,
        @ViewBuilder overlayContent: @escaping (_ state: Binding<PreviewState>) -> OverlayContent
    ) -> Preview<Action, PreviewState, Content, OverlayContent> {
        Preview<_, _, _, OverlayContent>(
            content,
            debugOverlay: overlayContent,
            overlayAlignment: alignment,
            state: state,
            maximizedPreviewFrame: maximizedPreviewFrame,
            onStart: onStart,
            actionHandler: actionHandler
        )
    }
}
