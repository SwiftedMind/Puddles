import SwiftUI

@resultBuilder public struct InterfaceDescriptionBuilder {

    public static func buildBlock() -> some InterfaceDescription {
        EmptyInterfaceDescription()
    }

    @available(*, unavailable, message: "Please use an InterfaceDescription")
    public static func buildPartialBlock(
        first content: some View
    ) -> some View {
        content
    }

    public static func buildPartialBlock(
        first content: some InterfaceDescription
    ) -> some InterfaceDescription {
        content
    }

    public static func buildPartialBlock(
        accumulated: some InterfaceDescription,
        next: some InterfaceDescription
    ) -> some InterfaceDescription {
        AccumulatedInterfaceDescription(accumulated: accumulated, next: next)
    }
}
