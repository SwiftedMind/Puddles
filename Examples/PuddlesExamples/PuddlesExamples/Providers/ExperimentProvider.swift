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

@MainActor final class ExperimentProvider: ObservableObject {

    struct Dependencies {
        var experiments: () -> IdentifiedArrayOf<Experiment>
    }

    private let dependencies: Dependencies

    @Published var experiments: IdentifiedArrayOf<Experiment>

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.experiments = dependencies.experiments()
    }

    func delete(_ experiment: Experiment) {
        experiments.remove(experiment)
    }
}

// MARK: - Live

extension ExperimentProvider {
    static var live: ExperimentProvider = {
        .mock // In this simple case, we can use the mock version
    }()
}

// MARK: - Mock

extension ExperimentProvider {
    static var mock: ExperimentProvider = {
        return .init(
            dependencies: .init(
                experiments: {
                    Mock.Experiment.all
                }
            )
        )
    }()
}
