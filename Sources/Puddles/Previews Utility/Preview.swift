import SwiftUI

/*
 previews broken
 */

/// A SwiftUI previews helper type allowing to take advantage of view interfacing by providing an in-place mechanism of reacting to the view's actions.
///
/// - Important: This is only meant to be used within previews!
///
/// For more details on the view interfacing concept, see ``ViewInterface``.
public struct Preview<Action, ViewInterface: Interface<Action>, ViewState, Content: View, Overlay: View>: View {
    @State var state: ViewState
    @StateObject var interface: ViewInterface

    var content: (_ interface: ViewInterface, _ state: Binding<ViewState>) -> Content
    var actionHandler: (_ action: Action, _ state: inout ViewState) async -> Void
    var onStart: ((_ state: Binding<ViewState>) async throws -> Void)?

    var overlayAlignment: Alignment = .bottom
    var overlay: (_ interface: ViewInterface) -> Overlay

    public init(
        @ViewBuilder _ content: @escaping (_ interface: ViewInterface, _ state: ViewState) -> Content,
        state: @autoclosure @escaping () -> ViewState,
        actionHandler: @escaping (_ action: Action, _ state: inout ViewState) async -> Void
    ) where Overlay == EmptyView {
        self._state = .init(wrappedValue: state())
        self._interface = .init(wrappedValue: .init())
        self.content = { content($0, $1.wrappedValue) }
        self.actionHandler = actionHandler
        self.overlay = {_ in EmptyView() }
    }

    public init(
        _ content: Content.Type,
        state: @autoclosure  @escaping () -> ViewState,
        actionHandler: @escaping (_ action: Action, _ state: inout ViewState) async -> Void
    ) where Content: InterfacingView, Content.Interface == ViewInterface, Content.ViewState == ViewState, Overlay == EmptyView {
        self._state = .init(wrappedValue: state())
        self._interface = .init(wrappedValue: .init())
        self.content = { Content.init(interface: $0, state: $1.wrappedValue) }
        self.actionHandler = actionHandler
        self.overlay = {_ in EmptyView() }
    }

    private init(
        @ViewBuilder _ content: @escaping (_ interface: ViewInterface, _ state: Binding<ViewState>) -> Content,
        @ViewBuilder overlay: @escaping (_ interface: ViewInterface) -> Overlay,
        overlayAlignment: Alignment,
        state: @autoclosure () -> ViewState,
        actionHandler: @escaping (_ action: Action, _ state: inout ViewState) async -> Void
    ) {
        self._state = .init(wrappedValue: state())
        self._interface = .init(wrappedValue: .init())
        self.content = content
        self.actionHandler = actionHandler
        self.overlay = overlay
        self.overlayAlignment = overlayAlignment
    }
    
    public var body: some View {
        content(interface, $state)
            .overlay(alignment: overlayAlignment) {
                overlay(interface)
            }
            .background(
                ViewLifetimeHelper {
                    try! await onStart?($state)
                } onDeinit: {}
            )
            .onReceive(interface.actionPublisher) { action in
                Task {
                    var state = state
                    await actionHandler(action, &state)
                    self.state = state
                }
            }
    }
    
    public func onStart(perform: @escaping (_ state: Binding<ViewState>) async throws -> Void) -> Preview {
        var copy = self
        copy.onStart = perform
        return copy
    }

    public func overlay<OverlayContent: View>(
        alignment: Alignment = .bottom,
        @ViewBuilder overlayContent: @escaping (_ interface: ViewInterface) -> OverlayContent
    ) -> Preview<Action, ViewInterface, ViewState, Content, OverlayContent> {
        Preview<_, _, _, _, OverlayContent>(
            content, overlay: overlayContent,
            overlayAlignment: alignment,
            state: state,
            actionHandler: actionHandler
        )
    }
}
