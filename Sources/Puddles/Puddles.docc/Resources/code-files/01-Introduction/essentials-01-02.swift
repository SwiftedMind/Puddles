import SwiftUI
import Puddles

struct Root: Coordinator {

    var entryView: some View {
        Text("Hello, World")
    }

    func navigation() -> some NavigationPattern {
        // Empty for now
    }

    func interfaces() -> some InterfaceObservation {
        // Empty for now
    }

}
