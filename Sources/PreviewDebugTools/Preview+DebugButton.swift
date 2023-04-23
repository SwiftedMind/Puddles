import SwiftUI
import Puddles

/// A button that is styled to look like a debug tool.
///
/// It has no special functionality. You can use any button you like for your debug overlays.
public struct DebugButton: View {

    var title: String
    var action: () -> Void

    /// A button that is styled to look like a debug tool.
    ///
    /// It has no special functionality. You can use any button you like for your debug overlays.
    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: {
            action()
        }, label: {
            Text(title)
                .minimumScaleFactor(0.5)
                .padding(6)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .foregroundColor(.red)
                        .opacity(0.8)
                }
                .shadow(radius: 5)
        })
        .buttonStyle(.plain)
    }
}



public struct PreviewDebugButton_Previews: PreviewProvider {
    public static var previews: some View {
        DebugButton("Test") {}
    }
}
