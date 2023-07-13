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
import Models
import MockData
import Puddles

struct NumberFactView: View {
    var numberFact: NumberFact

    var body: some View {
        if let content = numberFact.content {
            VStack(alignment: .leading) {
                Text("Number: \(numberFact.number)")
                    .font(.caption)
                    .fixedSize()
                Text(content)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
    }
}

private struct PreviewState {
    var numberFact: NumberFact = .init(number: 5, content: Mock.factAboutNumber(5))
}

struct NumberFactView_Previews: PreviewProvider {
    static var previews: some View {
        StateHosting(PreviewState()) { $state in
            List {
                NumberFactView(numberFact: state.numberFact)
                Section {
                    Button("Toggle Loading") {
                        if state.numberFact.content == nil {
                            state.numberFact.content = Mock.factAboutNumber(5)
                        } else {
                            state.numberFact.content = nil
                        }
                    }
                }
            }
            .animation(.default, value: state.numberFact)
        }
    }
}
