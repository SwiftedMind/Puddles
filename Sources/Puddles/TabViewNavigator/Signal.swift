import SwiftUI

@propertyWrapper
public struct Signal<Content>: DynamicProperty {
    @State var content: Content? = nil
    @State var id: UUID = .init()

    public var wrappedValue: Wrapped {
        .init(id: id, content: content) { content in
            send(content)
        }
    }

    public init() {

    }

    private func send(_ content: Content) {
        self.content = content
        id = .init()
    }

}

public extension Signal {
    struct Wrapped: Equatable {
        var id: UUID
        var content: Content?
        var onSend: (_ content: Content) -> Void

        public func send(_ content: Content) {
            onSend(content)
        }

        public static func == (lhs: Signal<Content>.Wrapped, rhs: Signal<Content>.Wrapped) -> Bool {
            lhs.id == rhs.id
        }
    }
}

struct HandleSignalModifier<Value>: ViewModifier {

    @State var didAppear: Bool = false
    private var signal: Signal<Value>.Wrapped
    private var handler: (_ value: Value) -> Void

    init(signal: Signal<Value>.Wrapped, handler: @escaping (_: Value) -> Void) {
        self.signal = signal
        self.handler = handler
    }

    // TODO: signal value is stored in appnavigator, so reopening threadedit will re-receive the signal
    // Idea: Use a StateObject inside "Signal" and set content to nil after it has been handled (without triggering objectWillChange, to prevent unnecessary view updates)
    func body(content: Content) -> some View {
        content
            .onAppear {
                defer { didAppear = true }
                guard !didAppear, let value = signal.content else { return }
                handler(value)
            }
            .onChange(of: signal) { newValue in
                guard let value = newValue.content else { return }
                handler(value)
            }
    }
}

public extension View {
    func handleSignal<Value>(
        _ signal: Signal<Value>.Wrapped,
        handler: @escaping (_ value: Value) -> Void
    ) -> some View {
        modifier(HandleSignalModifier(signal: signal, handler: handler))
    }
}
