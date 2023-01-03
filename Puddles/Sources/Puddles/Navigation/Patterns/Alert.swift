
import SwiftUI

/// Presents an alert with a message and a title.
public struct Alert<Actions: View, Message: View>: NavigationPattern {
    var title: String
    @Binding var isPresented: Bool
    @ViewBuilder var actions: Actions
    @ViewBuilder var message: Message

    public init(
        title: String,
        isPresented: Binding<Bool>,
        @ViewBuilder actions: () -> Actions,
        @ViewBuilder message: () -> Message
    ) {
        self.title = title
        self._isPresented = isPresented
        self.actions = actions()
        self.message = message()
    }
}

public extension Alert {
    var body: some View {
        Color.clear
            .alert(title, isPresented: $isPresented) {
                actions
            } message: {
                message
            }
    }
}

/// Presents an alert with a message using the given data to produce the alert’s content and a string variable as a title.
public struct AlertWithData<Actions: View, Message: View, Data>: NavigationPattern {
    var title: String
    @Binding var isPresented: Bool
    var data: Data?
    @ViewBuilder var actions: (Data) -> Actions
    @ViewBuilder var message: (Data) -> Message

    public init(
        title: String,
        isPresented: Binding<Bool>,
        presenting data: Data?,
        @ViewBuilder actions: @escaping (Data) -> Actions,
        @ViewBuilder message: @escaping (Data) -> Message
    ) {
        self.title = title
        self._isPresented = isPresented
        self.data = data
        self.actions = actions
        self.message = message
    }
}

public extension AlertWithData {
    var body: some View {
        Color.clear
            .alert(title, isPresented: $isPresented, presenting: data) { data in
                actions(data)
            } message: { data in
                message(data)
            }

    }
}
