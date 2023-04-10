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

// A simplified data model for the book list component
struct Book: Identifiable, Equatable, Hashable {
    var id = UUID()
    var name: String
    var description: String
}

extension Book {
    static var mock: Self {
        .leviathanWakes
    }

    static var leviathanWakes: Self {
        .init(name: "Leviathan Wakes", description: "Leviathan Wakes is a science fiction novel by James S. A. Corey, the pen name of American writers Daniel Abraham and Ty Franck. It is the first book in the Expanse series, followed by Caliban's War, Abaddon's Gate and six other novels.")
    }

    static var calibansWar: Self {
        .init(name: "Caliban's War", description: "Caliban's War is a 2012 science fiction novel by James S. A. Corey. It is about a conflict in the Solar System that involves Earth, Mars, and the Asteroid Belt. It is the second book in The Expanse series and is preceded by Leviathan Wakes. The third book, Abaddon's Gate, was released on June 4, 2013.")
    }
}
