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
import MockData
import Models

struct NumberFactStackView: View {
    var numberFacts: IdentifiedArrayOf<NumberFact>
    var interface: Interface<Action>

    var body: some View {
        ForEach(numberFacts) { fact in
            NumberFactView(numberFact: fact)
        }
        .onDelete { indexSet in
            interface.send(.deleteFacts(indexSet: indexSet))
        }
    }
}

extension NumberFactStackView {

    enum Action: Hashable {
        case deleteFacts(indexSet: IndexSet)
    }
}

private struct PreviewState {
    var numberFacts: IdentifiedArrayOf<NumberFact> = [.init(number: 42, content: "Test")]
}

struct NumberFactListView_Previews: PreviewProvider {
    static var previews: some View {
        StateHosting(PreviewState()) { $state in
            NumberFactStackView(numberFacts: state.numberFacts, interface: .consume({ action in
                switch action {
                case .deleteFacts(let indexSet):
                    state.numberFacts.remove(atOffsets: indexSet)
                }
            }))
            .overlay(alignment: .bottom) {
                Button("Add Fact") {
                    let number = Int.random(in: 0...10)
                    state.numberFacts.insert(.init(number: number, content: Mock.factAboutNumber(number)), at: 0)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .preferredColorScheme(.dark)
    }
}
