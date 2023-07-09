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
import IdentifiedCollections
import Models

/// A store that handles saving and loading of daily scrums.
///
/// They will be saved inside a file in the app's document directory.
public final class ScrumStore {

    public init() {}

    /// Loads and returns the stored array of daily scrums from disk.
    /// - Returns: The daily scrums array.
    public func load() async throws -> IdentifiedArrayOf<DailyScrum> {
        let task = Task<IdentifiedArrayOf<DailyScrum>, Error>.detached { [fileURL] in
            let fileURL = try fileURL()
            guard let file = try? FileHandle(forReadingFrom: fileURL) else { return [] }
            try Task.checkCancellation()
            return try JSONDecoder().decode(IdentifiedArrayOf<DailyScrum>.self, from: file.availableData)
        }
        return try await task.value
    }

    /// Stores the given array of daily scrums.
    /// - Parameter scrums: The daily scrums to store.
    public func save(_ scrums: IdentifiedArrayOf<DailyScrum>) async throws {
        let task = Task.detached { [fileURL] in
            let data = try JSONEncoder().encode(scrums)
            let outfile = try fileURL()
            try Task.checkCancellation()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }

    /// Returns the URL for the file that stores the scrums.
    /// - Returns: The URL.
    @Sendable private func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("scrums.data")
    }
}
