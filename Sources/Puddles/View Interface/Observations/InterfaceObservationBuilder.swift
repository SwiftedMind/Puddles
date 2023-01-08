import SwiftUI

@resultBuilder public struct InterfaceObservationBuilder {

    public static func buildBlock() -> some InterfaceObservation {
        EmptyInterfaceObservation()
    }

    @available(*, unavailable, message: "Please use an InterfaceObservation")
    public static func buildPartialBlock(
        first content: some View
    ) -> some View {
        content
    }
    
    public static func buildPartialBlock(
        first content: some InterfaceObservation
    ) -> some InterfaceObservation {
        content
    }

    public static func buildPartialBlock(
        accumulated: some InterfaceObservation,
        next: some InterfaceObservation
    ) -> some InterfaceObservation {
        AccumulatedInterfaceObservation(accumulated: accumulated, next: next)
    }
}
