import SwiftUI

/// A SwiftUI previews helper type allowing to take advantage of view interfacing by providing an in-place mechanism of reacting to the view's actions.
///
/// - Important: This is only meant to be used within previews!
///
/// For more details on the view interfacing concept, see ``Puddles/Interface``.
public struct Preview<Action, ViewInterface: Interface<Action>, ViewState, Content: View, Overlay: View>: View {
    @State var state: ViewState
    @StateObject var interface: ViewInterface

    var content: (_ interface: ViewInterface, _ state: Binding<ViewState>) -> Content
    var actionHandler: (_ action: Action, _ state: Binding<ViewState>) -> Void
    var onStart: ((_ state: Binding<ViewState>) async -> Void)?

    var maximizedPreviewFrame: Bool = false

    var overlayAlignment: Alignment = .bottom
    var debugOverlay: (_ state: Binding<ViewState>) -> Overlay

    /// A SwiftUI previews helper type allowing to take advantage of view interfacing by providing an in-place mechanism of reacting to the view's actions.
    ///
    /// - Important: This is only meant to be used within previews!
    public init(
        @ViewBuilder _ content: @escaping (_ interface: ViewInterface, _ state: ViewState) -> Content,
        state: @autoclosure @escaping () -> ViewState,
        actionHandler: @escaping (_ action: Action, _ state: Binding<ViewState>) -> Void
    ) where Overlay == EmptyView {
        self._state = .init(wrappedValue: state())
        self._interface = .init(wrappedValue: .init())
        self.content = { content($0, $1.wrappedValue) }
        self.actionHandler = actionHandler
        self.debugOverlay = {_ in EmptyView() }
    }

    private init(
        @ViewBuilder _ content: @escaping (_ interface: ViewInterface, _ state: Binding<ViewState>) -> Content,
        @ViewBuilder debugOverlay: @escaping (_ state: Binding<ViewState>) -> Overlay,
        overlayAlignment: Alignment,
        state: @autoclosure () -> ViewState,
        maximizedPreviewFrame: Bool,
        actionHandler: @escaping (_ action: Action, _ state: Binding<ViewState>) -> Void
    ) {
        self._state = .init(wrappedValue: state())
        self._interface = .init(wrappedValue: .init())
        self.content = content
        self.maximizedPreviewFrame = maximizedPreviewFrame
        self.actionHandler = actionHandler
        self.debugOverlay = debugOverlay
        self.overlayAlignment = overlayAlignment
    }
    
    public var body: some View {
        content(interface, $state)
            .frame(
                maxWidth: maximizedPreviewFrame ? .infinity : nil,
                maxHeight: maximizedPreviewFrame ? .infinity : nil
            )
            .overlay(alignment: overlayAlignment) {
                debugOverlay($state)
            }
            .background(
                ViewLifetimeHelper {
                    await onStart?($state)
                } onDeinit: {}
            )
            .onReceive(interface.actionPublisher) { action in
                actionHandler(action, $state)
            }
    }

    public func fullScreenPreview() -> Preview {
        var copy = self
        copy.maximizedPreviewFrame = true
        return copy
    }
    
    public func onStart(perform: @escaping (_ state: Binding<ViewState>) async -> Void) -> Preview {
        var copy = self
        copy.onStart = perform
        return copy
    }

    public func overlay<OverlayContent: View>(
        alignment: Alignment = .bottom,
        maximizedPreviewFrame: Bool = true,
        @ViewBuilder overlayContent: @escaping (_ state: Binding<ViewState>) -> OverlayContent
    ) -> Preview<Action, ViewInterface, ViewState, Content, OverlayContent> {
        Preview<_, _, _, _, OverlayContent>(
            content,
            debugOverlay: overlayContent,
            overlayAlignment: alignment,
            state: state,
            maximizedPreviewFrame: maximizedPreviewFrame,
            actionHandler: actionHandler
        )
    }
}
