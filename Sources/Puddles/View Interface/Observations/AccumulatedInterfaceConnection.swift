import SwiftUI

struct AccumulatedInterfaceObservation<Pattern: InterfaceObservation, Next: InterfaceObservation>: InterfaceObservation {

    var accumulated: Pattern
    var next: Next

    @inlinable var body: some View {
        accumulated.background(next)
    }
}
