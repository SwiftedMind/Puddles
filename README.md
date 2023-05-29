<p align="center">
  <img width="200" height="200" src="https://user-images.githubusercontent.com/7083109/231764991-1de9f379-2f2a-41e4-b396-d7592508b6ed.png">
</p>

# Puddles - A SwiftUI Architecture
![GitHub release (latest by date)](https://img.shields.io/github/v/release/SwiftedMind/Puddles?label=Latest%20Release)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftedMind%2FPuddles%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/SwiftedMind/Puddles)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftedMind%2FPuddles%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/SwiftedMind/Puddles)
![GitHub](https://img.shields.io/github/license/SwiftedMind/Puddles)

Puddles is an app architecture for apps built on the SwiftUI lifecycle. It tries to encourage building flexible, modular and scalable apps by providing a set of simple tools and patterns that make development easier and more convenient. However, it doesn't try to lock you into anything. Every project is unique and while it should be generally discouraged, it has to be easy to deviate from existing patterns. Puddles has been designed from the start with this thought in mind.

> **Note**
> This Readme is a bit outdated. Recently, I have made a lot of fundamental changes to the architecture and I'm working on updating the documentation as fast as possible.

- **[Features](#features)**
- [Installation](#installation)
- [Documentation](#documentation)
- [Examples](#examples)
- **[The Puddles Architecture](#the-puddles-architecture)**
- [Should you use Puddles?](#should-you-use-puddles)
- [License](#license)

## Features

➖ **Architecture** - Puddles diverges from strict MVVM in SwiftUI, opting for two main structures called `Provider` and `Navigator`, which are plain SwiftUI views. These structures wrap around your UI to handle logic and data management, while maintaining access to all SwiftUI features and techniques.

➖ **Native** - Since Provider and Navigator are SwiftUI views, they can be placed anywhere a SwiftUI view can be placed, offering flexibility in architecture. If Puddles' architecture doesn't suit your needs in specific cases, simply use alternative techniques and integrate them seamlessly.

➖ **Modularity** - Puddles is designed to encourage highly modular code by layering logic and dependencies in nested Providers, which can be swapped out easily and even be moved across different projects!

➖ **Unidirectional Data Flow** - Puddles is designed for one-way communication between components, reducing complexity and enhancing modularity and ease of use with SwiftUI Previews. It provides an `Interface` type for sending actions to an interface observer.

➖ **Deep Link Support** - Puddles includes built-in support for deep linking and arbitrary state restoration with minimal additional setup.

➖ [**Queryables**](https://github.com/SwiftedMind/queryable) - Queryables enable you to present a view and `await` its completion with a single async function call that automatically takes care of setting presentation state. This simplifies tasks like triggering a deletion confirmation alert and awaiting its result, all from a single scope.

➖ **Target States** - In SwiftUI, you can send data from a child view to a parent view through the use of closures, which are one-time events that trigger an action. Puddles introduces a `TargetState` concept that lets you send "one-time" data down the view hierarchy without enforcing a new state. This is particularly useful for deep linking and state restoration, allowing state changes from outside a view without locking new states from the parent.

## Installation

Puddles supports iOS 15+, macOS 12+, watchOS 8+ and tvOS 15+.

### In Swift Package

Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/SwiftedMind/Puddles", from: "1.0.0")
```

### In Xcode project

Go to `File` > `Add Packages...` and enter the URL "https://github.com/SwiftedMind/Puddles" into the search field at the top right. Puddles should appear in the list. Select it and click "Add Package" in the bottom right.

## Documentation

The documentation for Puddles can be found here:
[Documentation](https://swiftedmind.github.io/Puddles/documentation/puddles/)

## Examples

[**Scrumdinger**](https://github.com/SwiftedMind/Scrumdinger) - Apple's tutorial app re-implemented in Puddles (An awesome idea by the [Pointfree](https://www.pointfree.co/) guys to use Apple's tutorial app to test new ways of building SwiftUI apps).

[**ExploreAI**](https://github.com/SwiftedMind/GPTPlayground) - A simple app testing out some ideas for OpenAI's ChatGPT API (using my [GPTSwift](https://github.com/SwiftedMind/gptswift) framework as an interface)

## The Puddles Architecture

To get a more in-depth overview of the architecture, have a look at this article: [**The Puddles Architecture**](https://www.swiftedmind.com/blog/posts/introducing-puddles/01_architecture_intro).

![Puddles Architecture](https://user-images.githubusercontent.com/7083109/232222438-ca21b1f8-c87a-4b27-b6f2-05af6aacfc61.png)

SwiftUI encourages building views from the ground up, constructing increasingly complex UI by wrapping views in other views. With Puddles, you do the exact same thing, but also include data dependencies and navigational context in the layering.

### The View

![View Explanation](https://user-images.githubusercontent.com/7083109/232221735-9f21f3ca-669e-46b4-bf95-13a7d70434cf.png)

The View is at the base of the architecture. It contains a traditional SwiftUI `body` and behaves just like any other SwiftUI view. The only difference is that it is usually comprised of only two nonmutating properties, a `ViewState` and an `Interface`. The `ViewState` provides the view with all the data it needs to display itself whereas the `Interface` is a lightweight mechanism to send user interactions – like a button tap – upstream.

```swift
struct BookListView: View {
  // Only two properties
  var interface: Interface<Action> // Upstream communication
  var state: ViewState // Read-only state

  var body: some View {
    List {
      Button("Toggle Descriptions") {
        interface.send(.showDescriptionsToggled)
      }
      ForEach(state.books) { book in
        Button {
          interface.send(.bookTapped(book))
        } label: {
          VStack(alignment: .leading) {
            Text(book.name)
            if state.isShowingDescriptions {
              Text(book.description)
                .font(.caption)
            }
          }
        }
        .buttonStyle(.plain)
      }
    }
  }
}

extension BookListView {
  // The ViewState contains all the data that the view needs
  struct ViewState {
    var books: [Book]
    var isShowingDescriptions: Bool
  }
  enum Action {
    case showDescriptionsToggled
    case bookTapped(Book)
  }
}
```

### The View Provider

![View Provider Explanation](https://user-images.githubusercontent.com/7083109/232221825-311d810a-bd3c-407b-b379-5c0bf2a94529.png)

The View Provider is the owner of a View's state and is responsible for its data management. Effectively, this is the view's view model but instead of it being defined _inside_ the view, it is defined _around_ it. That's possible because a View Provider is just another SwiftUI view itself.

```swift
// This is actually a SwiftUI view. It manages the BookListView's state.
struct BookList: Provider {
  // Interface to send actions to a parent
  var interface: Interface<Action>

  // External dependency passed in from a parent, which is usually a data provider (but can be anything, really).
  var books: [Book]

  // View state lives here
  @State private var isShowingDescriptions: Bool = false

  // The entry view will be used to build the Provider's SwiftUI body
  var entryView: some View {
    BookListView(
      interface: .consume(handleViewInterface), // Handle the View's interface
      state: .init( // Create the View's state
        books: books,
        isShowingDescriptions: isShowingDescriptions
      )
    )
  }

  // React to user interaction and update the View's state
  @MainActor private func handleViewInterface(_ action: BookListView.Action) {
    switch action {
    case .showDescriptionsToggled:
      isShowingDescriptions.toggle()
    case .bookTapped(let book):
      // Relay this tap so that a navigator upstream can handle navigation
      interface.send(.bookTapped(book))
    }
  }

  // Here, you can define target states that you want to access easily by calling applyTargetState(.someState)
  func applyTargetState(_ state: TargetState) {
    switch state {
    case .reset:
      isShowingDescriptions = false
    }
  }
}

extension BookList {
  enum TargetState {
    case reset
  }
  enum Action: Hashable {
    case bookTapped(Book)
  }
}
```

### The Data Provider

![Data Provider Explanation](https://user-images.githubusercontent.com/7083109/232221879-de0a8fe5-4bde-409a-9cdf-297a0c36f51c.png)

Technically, a Data Provider is identical to a View Provider. The difference is only semantic in nature. A Data Provider is meant to wrap around a View Provider to add any kind of dependencies that the View Provider needs.

```swift
extension BookList {
  // A data provider for BookList. This one provides all of the user's favorite books
  struct Favorites: Provider {
    // A repository, service or manager can be used as an interface with a database or backend or anything else
    @EnvironmentObject private var favoriteBooksRepository: FavoriteBooksRepository

    // Relay for the BookList interface
    var interface: Interface<BookList.Action>

    // Here, the books live
    @State private var books: [Book] = []

    var entryView: some View {
      BookList(
        interface: .forward(to: interface), // Forward the interface
        books: books
      )
    }

    func start() async {
      do {
        // Fetch the books
        books = try await favoriteBooksRepository.fetchBooks()
      } catch {}
    }

    @MainActor func applyTargetState(_ state: TargetState) {
      switch state {
      case .reset:
        books = []
      }
    }
  }
}

extension BookList.Favorites {
  enum TargetState {
    case reset
  }
}
```

### The Navigator

![Navigator Explanation](https://user-images.githubusercontent.com/7083109/232221932-cfad854b-9ca2-446d-ac0d-467ae665b10f.png)

The Navigator takes care of coordinating the navigation inside a section of your app. It is responsible for managing a `NavigationStack`, `NavigationSplitView` or `TabView`, as well as presenting any kind of views via, for instance, `fullScreenCover`, `sheet`, or `alert`. You can think of each common view hierarchy inside your app having its own Navigator, i.e. a presented sheet would have its own Navigator at its root.

```swift
struct BooksNavigator: Navigator {
  @StateObject private var favoriteBooksRepository: FavoriteBooksRepository = .init()
  @State private var path: [Path] = []

   var entryView: some View {
    NavigationStack(path: $path) {
      // Set the BookList as root, with the favorites data provider fetching the books
      BookList.Favorites(interface: .consume(handleBookListInterface))
        .navigationDestination(for: Path.self) { path in
          destination(for: path)
        }
    }
    .environmentObject(favoriteBooksRepository)
  }

  @ViewBuilder @MainActor
  private func destination(for path: Path) -> some View {
    switch path {
    case .bookDetail(let book):
      Text(book.name)
    }
  }

  @MainActor
  private func handleBookListInterface(_ action: BookList.Action) {
    switch action {
    case .bookTapped(let book):
      path.append(.bookDetail(book))
    }
  }

  func applyTargetState(_ state: TargetState) {
    switch state {
    case .reset:
      path.removeAll()
    }
  }
}

extension BooksNavigator {
  enum TargetState: Hashable {
    case reset
  }

  enum Path: Hashable {
    case bookDetail(Book)
  }
}
```

## Should you use Puddles?

I designed and built Puddles around a few key ideas that fundamentally shaped the architecture with all its advantages, disadvantages and outright problems (I'm looking at you, *lack of unit testing support*).

First and foremost, **I didn't want to over-engineer anything**. While it is certainly possible – and totally valid– to solve a lot of problems and trade-offs by building layers upon layers onto what Swift and SwiftUI already provide, I wanted to stay as close to the native ecosystem as possible to not only allow for more flexibility and freedom, but to also keep everything as lightweight as possible. Right now, you could easily fork the repository and modify or maintain it yourself. It's not much code and most of it should be fairly straightforward. I would like to keep it that way, as much as possible.

Secondly, **I wanted something that's not following the traditional MVVM paradigm**. I know this is highly opinionated and possibly very, very wrong. But strict MVVM as we know it in SwiftUI simply doesn't feel right to me. This might change over time – maybe [SE-0395](https://forums.swift.org/t/se-0395-observability/64342) will help with that in some ways – and the good thing is that it should be relatively easy to pivot Puddles if need be. That's another reason why I designed it to be flexible and lightweight.

Thirdly, **I wanted to focus on data encapsulation** by making SwiftUI views host their own state. This makes working with the SwiftUI environment much easier. It also creates clear-cut responsibilities for every data point in the app thanks to the nature of read-only properties inside views.

The flip side of the coin is coupling your UI with your data, which can cause problems. For example, this makes it challenging to restore arbitrary states, which you would need for deep link support – though I do think that I have found a nice solution for that problem via the concept of Target States.

And finally, not separating views from their data source means that unit testing becomes basically impossible, since SwiftUI states only really work in a real SwiftUI environment. However, that might be solvable in the future, when Apple releases or exposes more API to work with.

With all that said, I'd like to lastly emphasize the fact that **Puddles might not be the best way to build your SwiftUI app**. You should always consider your needs, constraints and willingness to try something new and possibly risky. If you do decide to give Puddles a try, though, then I genuinely hope you enjoy it and succeed in building a modular and maintainable app.

## License

MIT License

Copyright (c) 2023 Dennis Müller and all collaborators

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
