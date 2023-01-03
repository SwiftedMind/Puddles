import SwiftUI
import Puddles
import Combine

struct HomeView: View {
    @ObservedObject var interface: Interface

    var body: some View {
        VStack {
          Text("Button tapped \(interface.buttonTapCount) times.")
          Button("Tap Me") {
              interface.sendAction(.buttonTapped)
          }
        }
    }

}

extension HomeView {
    @MainActor final class Interface: ViewInterface {
        var actionPublisher: PassthroughSubject<Action, Never> = .init()

        @Published var buttonTapCount: Int = 0
    }

    enum Action {
        case buttonTapped
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Preview(HomeView.init, interface: .init()) { action, interface in
            switch action {
            case .buttonTapped:
                interface.buttonTapCount += 1
            }
        }
        .onStart { interface in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            interface.buttonTapCount = 40
        }
    }
}

