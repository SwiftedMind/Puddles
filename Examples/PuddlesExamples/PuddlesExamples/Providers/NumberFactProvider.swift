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
import NumbersAPI

@MainActor final class NumberFactProvider: ObservableObject {

    struct Dependencies {
        var factAboutRandomNumber: () async throws -> String
        var factAboutNumber: (_ number: Int) async throws -> String
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func factAboutRandomNumber() async throws -> String {
        try await dependencies.factAboutRandomNumber()
    }

    func factAboutNumber(_ number: Int) async throws -> String {
        try await dependencies.factAboutNumber(number)
    }

}

// MARK: - Live

extension NumberFactProvider {
    static var live: NumberFactProvider = {
        let numbers = Numbers()
        return .init(dependencies: .init(
                factAboutRandomNumber: {
                    try await numbers.factAboutRandomNumber()
                }, factAboutNumber: { number in
                    try await numbers.factAboutNumber(number)
                }
            ))
    }()
}

// MARK: - Mock

extension NumberFactProvider {
    static var mock: NumberFactProvider = {
        .init(
            dependencies: .init(
                factAboutRandomNumber: {
                    "42 is the answer to life, the universe and everything in it!"
                }, factAboutNumber: { number in
                    "\(number) is an interesting number"
                }
            )
        )
    }()
}
