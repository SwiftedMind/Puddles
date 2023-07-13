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

@MainActor final class ExampleAdapter: ObservableObject {

    @Published var facts: IdentifiedArrayOf<NumberFact> = []
    private let numberFactProvider: NumberFactProvider
    private var availableNumbers: Set<Int> = Set(0...200)

    init(numberFactProvider: NumberFactProvider) {
        self.numberFactProvider = numberFactProvider
    }

    func fetchFactAboutRandomNumber() async throws {
        if let number = randomAvailableNumber() {
            let fact = NumberFact(number: number)
            facts.insert(fact, at: 0)
            let content = try await numberFactProvider.factAboutNumber(number)
            facts[id: fact.id]?.content = content
        }
    }

    func fetchRandomFact() {
        Task { try? await fetchFactAboutRandomNumber() }
    }

    func reset() {
        facts.removeAll()
        availableNumbers = Set(0...200)
    }

    func sort() {
        facts.sort(by: { $0.number < $1.number })
    }

    private func randomAvailableNumber() -> Int? {
        guard !availableNumbers.isEmpty else { return nil }
        availableNumbers = Set(availableNumbers.shuffled())
        return availableNumbers.removeFirst()
    }
}
