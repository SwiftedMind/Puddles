//
//  Copyright © 2023 Dennis Müller and all collaborators
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI
import Puddles

struct HomeView: View {
    @ObservedObject var interface: Interface<Action>
    let state: ViewState

    var body: some View {
        VStack {
            Text("Button tapped \(state.buttonTapCount) times.")
            Button("Tap Me") {
                interface.sendAction(.buttonTaped)
            }
        }
    }

}

extension HomeView {

    struct ViewState {
        var buttonTapCount: Int

        init(buttonTapCount: Int = 0) {
            self.buttonTapCount = buttonTapCount
        }

        static var mock: ViewState {
            .init(buttonTapCount: 10)
        }
    }

    enum Action {
        case buttonTaped
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Preview(HomeView.init, state: .mock) { action, $state in
            switch action {
            case .buttonTaped:
                state.buttonTapCount += 1
            }
        }
        .fullScreenPreview()
        .onStart { $state in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            state.buttonTapCount = 40
        }
        .overlay(alignment: .bottom) { $state in
            Button("Reset") {
                state.buttonTapCount = 0
            }
        }
    }
}
