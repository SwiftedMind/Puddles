import SwiftUI
import Puddles

public struct DebugButton: View {

    var title: String
    var action: () -> Void

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
                        .foregroundColor(Color(uiColor: .systemRed))
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
