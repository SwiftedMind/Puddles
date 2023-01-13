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

public enum LoadingState<Value, Error: Swift.Error> {
    case initial
    case loading
    case loaded(Value)
    case failure(Error)

    public var value: Value? {
        switch self {
        case .initial, .loading, .failure:
            return nil
        case .loaded(let value):
            return value
        }
    }

    public var isLoading: Bool {
        switch self {
        case .initial, .loaded, .failure:
            return false
        case .loading:
            return true
        }
    }

    public var isFailure: Bool {
        switch self {
        case .initial, .loaded, .loading:
            return false
        case .failure:
            return true
        }
    }

    public var isLoaded: Bool {
        switch self {
        case .initial, .failure, .loading:
            return false
        case .loaded:
            return true
        }
    }
}


extension LoadingState: Equatable where Value: Equatable {

    public static func == (lhs: LoadingState<Value, Error>, rhs: LoadingState<Value, Error>) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.loading, .loading):
            return true
        case (.loaded(let left), .loaded(let right)):
            return left == right
        case (.failure, .failure):
            return true // Technically wrong!
        default:
            return false
        }
    }
}
