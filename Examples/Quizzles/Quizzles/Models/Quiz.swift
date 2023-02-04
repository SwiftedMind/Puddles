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

import Foundation
import IdentifiedCollections

public struct Quiz: Identifiable, Hashable, Sendable {
    public var id: UUID = .init()
    public var name: String
    public var items: IdentifiedArrayOf<Item> = []

    public struct Item: Identifiable, Hashable, Sendable {
        public var id: UUID = .init()
        public var question: String
        public var answer: String
    }
}

public extension Quiz {

    static var draft: Quiz {
        .init(name: "", items: [])
    }

    static var mock: Quiz {
        .init(name: "The Quiz about Space", items: [.mock])
    }

    static var random: Quiz {
        .init(name: faker.name.name(), items: .repeating(.mock, count: 5))
    }

    private static var list: [Quiz] {
        [
            
        ]
    }
}

public extension Quiz.Item {

    static var mock: Quiz.Item {
        .init(question: "What is the name of the only habitable planet in the solar system?", answer: "Earth")
    }

    static var random: Quiz.Item {
        .init(question: faker.name.name(), answer: faker.name.name())
    }
}
