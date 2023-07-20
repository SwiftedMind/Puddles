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

import Puddles
import SwiftUI
import Queryable
import Models

struct QueryableExample: View {
    @EnvironmentObject private var experimentProvider: ExperimentProvider
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var queryableExampleRouter = Router.shared.queryableExample

    var body: some View {
        NavigationStack {
            List {
                if experimentProvider.experiments.isEmpty {
                    Text("Finally, some silence!")
                }
                ForEach(experimentProvider.experiments) { experiment in
                    ExperimentListSection(experiment: experiment) {
                        requestDeletion(of: experiment)
                    }
                }
            }
            .animation(.default, value: experimentProvider.experiments)
            .queryableAlert(controlledBy: queryableExampleRouter.deletionConfirmation, title: "Delete this experiment?") { _, query in
                Button("Yes") { query.answer(with: true) }
                Button("No") { query.answer(with: false) }
            } message: {_ in}
            .navigationTitle("Experiment Ideas")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func requestDeletion(of experiment: Experiment) {
        Task {
            do {
                if try await queryableExampleRouter.queryDeletionConfirmation() {
                    experimentProvider.delete(experiment)
                }
            } catch {}
        }
    }

}

struct QueryableExample_Previews: PreviewProvider {
    static var previews: some View {
        QueryableExample()
            .withMockProviders()
            .preferredColorScheme(.dark)
    }
}

