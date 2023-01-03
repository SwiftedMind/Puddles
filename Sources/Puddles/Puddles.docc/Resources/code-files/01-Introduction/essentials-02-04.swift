import SwiftUI
import Puddles
import Combine

struct HomeView: View {
    @ObservedObject var interface: Interface

    var body: some View {
        VStack {
          Text("Button tapped \(interface.buttonTapCount) times.")
          Button("Tap Me") {
              interface.buttonTapped()
          }
        }
    }

}

extension HomeView {
    @MainActor final class Interface: ViewInterface {
        var actionPublisher: PassthroughSubject<NoAction, Never> = .init()

        @Published var buttonTapCount: Int = 0

        func buttonTapped() {
            buttonTapCount += 1
        }
    }
}
