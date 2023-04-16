<p align="center">
  <img width="200" height="200" src="https://user-images.githubusercontent.com/7083109/231764991-1de9f379-2f2a-41e4-b396-d7592508b6ed.png">
</p>

# Puddles - A SwiftUI Architecture
![GitHub release (latest by date)](https://img.shields.io/github/v/release/SwiftedMind/Puddles?label=Latest%20Release)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftedMind%2FPuddles%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/SwiftedMind/Puddles)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftedMind%2FPuddles%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/SwiftedMind/Puddles)
![GitHub](https://img.shields.io/github/license/SwiftedMind/Puddles)

Puddles is an app architecture for apps built on the SwiftUI lifecycle. It tries to encourage building flexible, modular and scalable apps by providing a set of simple tools and patterns that make development easier and more convenient. However, it doesn't try to lock you into anything. Every project is unique and while it should be generally discouraged, it has to be easy to deviate from existing patterns. Puddles has been designed from the start with this thought in mind.


- **[Features](#features)**
- [Installation](#installation)
- [Documentation](#documentation)
- **[The Puddles Architecture](#the-puddles-architecture)**
- [Should you use Puddles?](#should-you-use-puddles)
- [Frequently Asked Questions](#frequently-asked-questions)
- [License](#license)

## Features

➖ **Architecture** - Puddles diverges from strict MVVM in SwiftUI, opting for two main structures called `Provider` and `Navigator`, which are plain SwiftUI views. These structures wrap around your UI to handle logic and data management, while maintaining access to all SwiftUI features and techniques.

➖ **Modular** - Puddles is designed to encourage highly modular code by layering logic and dependencies in nested `Providers`, which can be swapped out easily and even be moved across different projects!

➖ **Flexible** - Since `Provider` and `Navigator` are SwiftUI views, they can be placed anywhere a SwiftUI view can be placed, offering flexibility in architecture. If Puddles' architecture doesn't suit your needs in specific cases, simply use alternative techniques and integrate them seamlessly.

➖ **Designed to Feel Native** - Puddles is built to integrate with SwiftUI API without relying on hacks, workarounds, or internal methods. Many implementations are convenient wrappers around existing interfaces.

➖ **Unidirectional Data Flow** - Puddles is designed for one-way communication between components, reducing complexity and enhancing modularity and ease of use with SwiftUI Previews. It provides an `Interface` type for sending actions to an interface observer.

➖ **Deep Link Support** - Puddles includes built-in support for deep linking and arbitrary state restoration with minimal additional setup.

➖ **Queryables** - Queryables enable you to present a view and `await` its completion with a single async function call that automatically takes care of setting presentation state. This simplifies tasks like triggering a deletion confirmation alert and awaiting its result, all from a single scope.

➖ **Target States** - In SwiftUI, you can send data from a child view to a parent view through the use of closures, which are one-time events that trigger an action. Puddles introduces a `TargetState` concept that lets you send "one-time" data down the view hierarchy without enforcing a new state. This is particularly useful for deep linking and state restoration, allowing state changes from outside a view without locking new states from the parent.

## Installation

Puddles supports iOS 15+, macOS 12+, watchOS 8+ and tvOS 15+.

### In Swift Package

Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/SwiftedMind/Puddles", branch: "main")
```

### In Xcode project

Go to `File` > `Add Packages...` and enter the URL "https://github.com/SwiftedMind/Puddles" into the search field at the top right. Puddles should appear in the list. Select it and click "Add Package" in the bottom right.

## Documentation

The documentation for Puddles can be found here:
[Documentation](https://swiftedmind.github.io/Puddles/documentation/puddles/)

Tutorials can be found here:
[Tutorials](https://swiftedmind.github.io/Puddles/tutorials/puddlestutorials)

# The Puddles Architecture

SwiftUI encourages building views from the ground up, constructing increasingly complex UI by wrapping views in other views. With Puddles, you do the exact same thing, but also include data dependencies and navigational context in the layering.

![Architecture Overview](https://user-images.githubusercontent.com/7083109/226821969-2b5681db-ba80-414a-9262-a56b637d8fde.png)

Starting from the base view that describes the UI of a screen or component, you add a wrapper view that provides and manages the view's state. This wrapper essentially subsumes the tasks of a traditional view model with the key distinction that it is still a view itself, meaning it has access to the full suite of features that the SwiftUI environment provides. 

You would then have additional wrapper views that add data dependencies – like a backend or database – to pass down to the layers below. This keeps everything really modular. You can switch out a backend dependency without the underlying views ever knowing or caring about it.

Let's have a look at the individual layers and their respective purpose by building a small example component that displays a list of books. Here's a simple data model that we will be using throughout:

```swift
// A simplified data model for the book list component
struct Book: Identifiable, Equatable, Hashable {
  var id = UUID()
  var name: String
  var description: String
}
```

## The View

![View Explanation](https://user-images.githubusercontent.com/7083109/224484750-8aae5d3d-9c4b-4e26-955d-b95c0ccd2ea1.png)

The View is at the base of the architecture. It contains a traditional SwiftUI `body` and behaves just like any other SwiftUI view. The only difference is that it is usually comprised of only two nonmutating properties, a `ViewState` and an `Interface`. The `ViewState` provided the view with all the data it needs to display itself whereas the `Interface` is a lightweight mechanism to send user interactions – like a button tap – upstream.

Importantly, the View cannot change its own state. That is by design. Puddles is designed around the notion of _unidirectional data flow_. Any information comes in through the `ViewState` and exits through the `Interface`, creating an easily understandable flow of data in a single direction. 

This frees the View of any kind of context or responsibility, making it reusable and highly modular. It is literally just the description of your UI and that's it. All kinds of logic and data handling happens upstream, in the View Provider.

Here's the view for our book list example:

```swift
struct BookListView: View {
  // Only two properties
  var interface: Interface<Action> // Upstream communication
  var state: ViewState // Read-only state

  var body: some View {
    List {
      Button("Toggle Descriptions") {
        interface.fire(.showDescriptionsToggled)
      }
      ForEach(state.books) { book in
        Button {
          interface.fire(.bookTapped(book))
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

## The View Provider

![View Provider Explanation](https://user-images.githubusercontent.com/7083109/224484721-07a7c5d3-5cb9-4804-8911-442bf6ce0214.png)

The View Provider is the owner of a View's state and is responsible for its data management. Effectively, this is the view's view model but instead of it being defined *inside* the view, it is defined *around* it. That's possible because a View Provider is just another SwiftUI view itself. 

Not only does this free the view from any kind of context – making it highly modular – it also means that the View Provider has access to all the amazing features SwiftUI has to offer, like the environment.

Moreover, we also gain better control over the encapsulation of the View's data. With traditional view models, all of the state properties – marked with `@Published` – have to have a public getter and often a public setter as well (for access to bindings). This exposes everything and makes it unclear who is actually responsible for managing the state, since technically anyone can read and write to it. As mentioned above, Puddles is all about unidirectional data flow which means it should always be clear where information is coming from and where it is going. And that is exactly what the concept of a View Provider gives us. They are not defined *laterally*, but rather *vertically*, keeping a clear and concise flow of information both upstream *and* downstream.

Here's the View Provider for our example. Notice the `entryView` property – which you can think of as the `Provider`'s `body` – and the `BookList`'s own `Interface`, which is used to send information upstream, just like with a View.
  
```swift
// This is actually a SwiftUI view. It manages the BookListView's state.
struct BookList: Provider {
  // Interface to send actions to a parent
  var interface: Interface<Action>

  // External dependency passed in from a parent, which is usually a Dependency Provider (but can be anything, really).
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
      interface.fire(.bookTapped(book))
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

## The Dependency Provider

![Dependency Provider Explanation](https://user-images.githubusercontent.com/7083109/226828345-0460c86c-70da-49b3-a007-7b9e0344b350.png)

Technically, a Dependency Provider is identical to a View Provider. The difference is only semantic in nature. A Dependency Provider is meant to wrap around a View Provider to add any kind of dependencies that the View Provider needs.

In our example, we have a `FavoriteBooksRepository` that fetches the user's favorite books. The `BookList.Favorites` Dependency Provider uses that repository to fetch and provide the books to the `BookList` View Provider.

Again, this layered approach to building a SwiftUI app allows you to easily swap out dependencies. All the `BookList` View Provider does, is accept an array of books without assuming anything about it. For instance, you could create a new Dependency Provider `BookList.ReadingList` that fetches the user's reading list and provides those books to `BookList`.

For our book list example, the Dependency Provider could look like this:

```swift
extension BookList {
  // A Dependency Provider for BookList. This one provides all of the user's favorite books
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

One interesting thing to note here is that the Dependency Provider forwards all actions from the View Provider interface. Usually, this is the sensible thing to do, since a Dependency Provider (mostly) only adds dependencies and should not control the behavior of its underlying View Provider. Instead, that should be handled upstream.

Effectively, a Dependency Provider provides a reduced version of a View Provider's initializer:

```swift
BookList(interface:books:) // Books need to be provided
BookList.Favorites(interface:) // The books are fetched and managed internally
```

### Data Interfaces

Sometimes, the View Provider needs to make a request to modify its data. For example, if a reload button has been tapped, or a filter or search query has changed. Since the Dependency Provider usually forwards the View Provider's interface without intercepting it, you can define an additional `dataInterface` that handles all actions around the data.

For our example, it could look like this:

```swift
// View Provider
struct BookList: Provider {
  var interface: Interface<Action>
  var dataInterface: Interface<DataAction> // Additional data interface
  var books: [Book]
  // ...
}

extension BookList {
  enum DataAction: Hashable {
    case reloadBooks
    case filterChanged(Filter)
    case searchQueryChanged(String)
  }
}

// Dependency Provider
extension BookList {
  struct Favorites: Provider {
    var interface: Interface<BookList.Action>
    var entryView: some View {
      BookList(
        interface: .forward(to: interface),
        dataInterface: .consume(handleDataInterface), // handle data interface
        books: books
      )
    }
          
    @MainActor private func handleDataInterface(_ action: BookList.DataAction) {/* ... */}
    // ...
  }
}
```

  
## The Navigator

![Navigator Explanation](https://user-images.githubusercontent.com/7083109/224484737-5e204683-69cd-43f1-ac0c-4dfaff8c38c3.png)

*[Work in Progress]*

```swift
// A Navigator is also just a SwiftUI view. It manages a navigational path.
struct BooksNavigator: Navigator {
  @StateObject private var favoriteBooksRepository: FavoriteBooksRepository = .init()
  @State private var path: [Path] = []

   var entryView: some View {
    NavigationStack(path: $path) {
      // Set the BookList as root, with the favorites Dependency Provider fetching the books
      BookList.favorites(interface: .consume(handleBookListInterface))
        .navigationDestination(for: Path.self) { path in
          destination(for: path)
        }
    }
    .environmentObject(favoriteBooksRepository)
  }

  func applyTargetState(_ state: TargetState) {
    switch state {
    case .reset:
      path.removeAll()
    }
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

---

## Should you use Puddles?

Finding a solid foundation to build well-structured apps based on the SwiftUI lifecycle has been a challenging problem since the framework's release. While SwiftUI excels at fast paced composition of view hierarchies, it is surprisingly easy to create lots of hard couplings between logic and UI, making it virtually impossible to keep a project modular and flexible. 

Navigation and data management in particular have been troublesome. Both should not be part of UI code since a view is supposed to be agnostic of its context. However, moving the logic too far away means losing out on all the great features that SwiftUI has to offer, like the `Environment` or automatic lifetime management of data. Puddles strives to strike a balance.

Puddles is trying to be as flexible and dynamic as possible. Every app is unique and requires specific ways of doing things, and being locked into a very strict architecture can quickly become frustrating. 

Puddles attempts to offer a helpful guidance and structure for your app, but does not force you into anything. It is built to be fully compatible with any other SwiftUI project, allowing you to incrementally adopt Puddles in existing projects, as well as link to any traditional SwiftUI view from within the scope of a Puddle `Provider` or `Navigator`.

### Why not to use Puddles

**Puddles is not battle-tested**

Puddles is still a new framework and things might change a lot. You will likely find yourself refactoring your code often, should you decide to use Puddles. Hopefully, this will improve over time as more and more projects are built with this architecture.

**No proper support for unit testing**

One of the major shortcomings right now is the lack of proper support for unit testing. If you need that, Puddles is not the right choice for now. I will look into it once the rest of the framework has stabilized.

## Frequently Asked Questions

*[Work in Progress]*

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
