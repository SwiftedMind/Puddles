import SwiftUI

/// A SwiftUI previews helper type allowing to take advantage of view interfacing by providing an in-place mechanism of reacting to the view's actions.
///
/// - Important: This is only meant to be used within previews!
///
/// For more details on the view interfacing concept, see `Interface`.
public struct Preview<Action, PreviewState, Content: View, Overlay: View>: View {
    @State var state: PreviewState

    var content: (_ interface: Interface<Action>, _ state: Binding<PreviewState>) -> Content
    var actionHandler: (_ action: Action, _ state: Binding<PreviewState>) -> Void
    var onStart: ((_ state: Binding<PreviewState>) -> Void)?

    var maximizedPreviewFrame: Bool = false

    var overlayAlignment: Alignment = .bottom
    var debugOverlay: (_ state: Binding<PreviewState>) -> Overlay

    /// A SwiftUI previews helper type allowing to take advantage of view interfacing by providing an in-place mechanism of reacting to the view's actions.
    ///
    /// - Important: This is only meant to be used within previews!
    ///
    /// For more details on the view interfacing concept, see `Interface`.
    public init(
        state: @autoclosure @escaping () -> PreviewState,
        interfaceAction: Action.Type,
        @ViewBuilder _ content: @escaping (_ interface: Interface<Action>, _ state: Binding<PreviewState>) -> Content,
        actionHandler: @escaping (_ action: Action, _ state: Binding<PreviewState>) -> Void
    ) where Overlay == EmptyView {
        self._state = .init(wrappedValue: state())
        self.content = { content($0, $1) }
        self.actionHandler = actionHandler
        self.debugOverlay = {_ in EmptyView() }
    }

    // Private helper initializer used for view modifiers.
    private init(
        @ViewBuilder _ content: @escaping (_ interface: Interface<Action>, _ state: Binding<PreviewState>) -> Content,
        @ViewBuilder debugOverlay: @escaping (_ state: Binding<PreviewState>) -> Overlay,
        overlayAlignment: Alignment,
        state: @autoclosure () -> PreviewState,
        maximizedPreviewFrame: Bool,
        onStart: ((_ state: Binding<PreviewState>) -> Void)?,
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
        content(.consume { actionHandler($0, $state) }, $state)
            .frame(
                maxWidth: maximizedPreviewFrame ? .infinity : nil,
                maxHeight: maximizedPreviewFrame ? .infinity : nil
            )
            .overlay(alignment: overlayAlignment) {
                debugOverlay($state)
            }
            .onAppear {
                onStart?($state)
            }
    }

    /// Maximizes the preview's frame.
    ///
    /// Use this if you preview a view component with a small frame, to allow more spacing for adding debug buttons or other utility.
    /// - Returns: A `Preview` whose frame is maximized.
    public func fullScreenPreview() -> Preview {
        var copy = self
        copy.maximizedPreviewFrame = true
        return copy
    }

    /// Adds an action to the `Preview` that is called before the preview appears.
    ///
    /// Use this to modify the state before it is being used to render the view.
    ///
    /// - Parameter perform: The action to trigger.
    /// - Returns: A `Preview` with an action that is called before the preview appears.
    public func onStart(perform action: @escaping (_ state: Binding<PreviewState>) -> Void) -> Preview {
        var copy = self
        copy.onStart = action
        return copy
    }

    /// Layers the views that you specify in front of this view.
    ///
    /// This behaves similar to the native `.overlay(_:content:)` view modifier, but the view builder closure provides you a binding to the preview state.
    ///
    /// - Parameters:
    ///   - alignment: The alignment that the modifier uses to position the
    ///     implicit ``ZStack`` that groups the foreground views. The default
    ///     is ``Alignment/center``.
    ///   - maximizedPreviewFrame: A flag indicating if the preview view should have its frame maximized to make room for the overlay views.
    ///   - overlayContent: The actual overlay content.
    /// - Returns: A view that uses the specified content as a foreground.
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
