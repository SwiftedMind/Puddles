import SwiftUI
import Puddles

struct MyView: View {
    @ObservedObject var interface: Interface

    var body: some View {
        Button("Delete") {
            interface.sendAction(.deleteButtonTapped)
        }
    }
}

extension MyView {
    @MainActor final class Interface: ViewInterface {
        var actionPublisher: PassthroughSubject<Action, Never> = .init()
    }

    enum Action {
        case deleteButtonTapped
    }
}
