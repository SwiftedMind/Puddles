import SwiftUI

struct AccumulatedInterfaceDescription<Pattern: InterfaceDescription, Next: InterfaceDescription>: InterfaceDescription {

    var accumulated: Pattern
    var next: Next

    @inlinable var body: some View {
        accumulated.background(next)
    }
}
