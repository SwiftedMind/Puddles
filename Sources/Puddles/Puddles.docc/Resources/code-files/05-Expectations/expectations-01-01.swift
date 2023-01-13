import SwiftUI
import Puddles

struct QueryableDemoView: View {
    @ObservedObject var interface: Interface<Action>
    let state: ViewState

    var body: some View {
        Button("Delete") {
            interface.sendAction(.deleteButtonTapped)
        }
    }

}

extension QueryableDemoView {

    struct ViewState {

    }

    enum Action {
        case deleteButtonTapped
    }
}
