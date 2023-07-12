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
import CultureMinds

@MainActor final class CultureMindsProvider: ObservableObject {

    struct Dependencies {
        var randomName: () -> String
        var allNames: () -> [String]
        var generateNames: () -> AsyncStream<String>
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func randomName() -> String {
        dependencies.randomName()
    }

    func allNames() -> [String] {
        dependencies.allNames()
    }

    func generateNames() -> AsyncStream<String> {
        dependencies.generateNames()
    }

}

// MARK: - Live

extension CultureMindsProvider {
    static var live: CultureMindsProvider = {
        let cultureMinds = CultureMinds()
        return .init(
            dependencies: .init(
                randomName: {
                    cultureMinds.randomName()
                }, allNames: {
                    cultureMinds.allNames()
                }, generateNames: {
                    cultureMinds.generateNames()
                }
            )
        )
    }()
}

// MARK: - Mock

extension CultureMindsProvider {
    static var mock: CultureMindsProvider = {
        .live // In this simple case, we can use the live version for the mocks as well
    }()
}
