import SwiftUI
import Puddles
import Combine

struct HomeView: View {
    @ObservedObject var interface: Interface

    var body: some View {
        Text("Hello, World")
    }

}

extension HomeView {
    @MainActor final class Interface: ViewInterface {
        var actionPublisher: PassthroughSubject<NoAction, Never> = .init()
    }
}
