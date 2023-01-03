import SwiftUI

/// A SwiftUI previews helper type allowing to take advantage of view interfacing by providing an in-place mechanism of reacting to the view's actions.
///
/// - Important: This is only meant to be used within previews!
///
/// For more details on the view interfacing concept, see ``ViewInterface``.
public struct Preview<Interface: ViewInterface, Content: View, Overlay: View>: View {
    @StateObject var interface: Interface

    var content: (_ interface: Interface) -> Content
    var actionHandler: (_ action: Interface.Action, _ interface: Interface) async -> Void
    var onStart: ((_ interface: Interface) async -> Void)?

    var overlayAlignment: Alignment = .bottom
    var overlay: (_ interface: Interface) -> Overlay

    public init(
        @ViewBuilder _ content: @escaping (_ interface: Interface) -> Content,
        interface: @autoclosure () -> Interface,
        actionHandler: @escaping (_ action: Interface.Action, _ interface: Interface) async -> Void
    ) where Overlay == EmptyView {
        let interfaceInstance = interface()
        self._interface = .init(wrappedValue: interfaceInstance)
        self.content = content
        self.actionHandler = actionHandler
        self.overlay = {_ in EmptyView() }
    }

    public init(
        _ content: Content.Type,
        interface: @autoclosure () -> Interface,
        actionHandler: @escaping (_ action: Interface.Action, _ interface: Interface) async -> Void
    ) where Content: InterfacingView, Content.Interface == Interface, Overlay == EmptyView {
        let interfaceInstance = interface()
        self._interface = .init(wrappedValue: interfaceInstance)
        self.content = { Content.init(interface: $0) }
        self.actionHandler = actionHandler
        self.overlay = {_ in EmptyView() }
    }

    private init(
        @ViewBuilder _ content: @escaping (_ interface: Interface) -> Content,
        @ViewBuilder overlay: @escaping (_ interface: Interface) -> Overlay,
        overlayAlignment: Alignment,
        interface: @autoclosure () -> Interface,
        actionHandler: @escaping (_ action: Interface.Action, _ interface: Interface) async -> Void
    ) {
        let interfaceInstance = interface()
        self._interface = .init(wrappedValue: interfaceInstance)
        self.content = content
        self.actionHandler = actionHandler
        self.overlay = overlay
        self.overlayAlignment = overlayAlignment
    }
    
    public var body: some View {
        content(interface)
            .overlay(alignment: overlayAlignment) {
                overlay(interface)
            }
            .background(
                ViewLifetimeHelper(cancelOnDeinit: false) {
                    await onStart?(interface)
                } onDeinit: {}
            )
            .onReceive(interface.actionPublisher) { action in
                Task {
                    await actionHandler(action, interface)
                }
            }
    }
    
    public func onStart(perform: @escaping (_ interface: Interface) async -> Void) -> Preview {
        var copy = self
        copy.onStart = perform
        return copy
    }

    public func overlay<OverlayContent: View>(
        alignment: Alignment = .bottom,
        @ViewBuilder overlayContent: @escaping (_ interface: Interface) -> OverlayContent
    ) -> Preview<Interface, Content, OverlayContent> {
        Preview<_, _, OverlayContent>(
            content, overlay: overlayContent,
            overlayAlignment: alignment,
            interface: interface,
            actionHandler: actionHandler
        )
    }
}
