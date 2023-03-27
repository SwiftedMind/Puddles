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

/// A type that can decode urls and turn them into target states for the app.
@MainActor
final class DeepLinkHandler: ObservableObject {

    init() {}

    static func targetState(for url: URL) -> Root.TargetState? {
        // To test, run this in a console (replace the URL with one of the options below):
        // xcrun simctl openurl booted "scrumdinger://createEmptyScrum"
        switch url.absoluteString {
        case let value where value.contains("createEmptyScrum"):
            return .createScrum(draft: .draft)
        case let value where value.contains("createMockScrum"):
            return .createScrum(draft: .mock)
        case let value where value.contains("editRandomScrum"):
            return .editRandomScrumOnDetailPage
        case let value where value.contains("showScrum"):
            guard let parameters = url.queryParameters else { return nil }
            guard let id = parameters["id"], let uuid = UUID(uuidString: id) else { return nil }
            return .showScrumById(uuid)
        case let value where value.contains("startMeeting"):
            guard let parameters = url.queryParameters else { return nil }
            guard let id = parameters["scrumId"], let uuid = UUID(uuidString: id) else { return nil }
            return .startMeetingForScrumWithId(uuid)
        default:
            return nil
        }
    }
}

private extension URL {
    var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
