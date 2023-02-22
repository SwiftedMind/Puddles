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
        public var content: Content?
        var onSend: (_ content: Content) -> Void

        public func send(_ content: Content) {
            onSend(content)
        }

        public static func == (lhs: Signal<Content>.Wrapped, rhs: Signal<Content>.Wrapped) -> Bool {
            lhs.id == rhs.id
        }
    }
}
