<img width="140px" src="https://user-images.githubusercontent.com/7083109/224485383-15c5798b-a916-4354-bcde-bc9cc951520b.png">

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

♦️ **Architecture** - Though it might be a controversial opinion, I am not convinced that strict MVVM is the right pattern to use within SwiftUI. You lose a lot of functionality and often have to work against the framework. That's why Puddles' main structures – `Provider` and `Navigator` – are just plain old SwiftUI views. They act as a wrapper around your actual UI and handle logic and data management. This allows you to make use of *all* the cool features and techniques SwiftUI provides.

♦️ **Modular**- Puddles is designed to encourage highly modular code by layering logic and dependencies in nested `Providers`, which can be swapped out easily and even be moved across different projects!

♦️ **Flexible** - `Provider` and `Navigator` being SwiftUI views has another huge advantage. They can be placed *anywhere* you could place any SwiftUI view, so you are not locked into the architecture. If you need to implement something that doesn't properly fit within the Puddles architecture, simply build it using different techniques and plug it in. **No problem!**

♦️ **Designed to Feel Native** - Puddles has been designed from the ground up to fit right in with the existing SwiftUI API. The framework does not use any kind of hack, workaround or SwiftUI internal methods. Everything is built using standard functionality. Many implementations are just convenient wrappers around existing interfaces.

♦️ **Unidirectional Data Flow** - While not strictly enforced by the framework, Puddles is designed around one-way communication between components. This greatly reduces complexity while increasing modularity and ease of use in SwiftUI Previews. To do this, Puddles provides an easy to use `Interface` type that lets you send `actions` to an interface observer.

♦️ **Deep Link Support** - Support for deep linking and arbitrary state restoration is built-in from the start and does not require much extra work or setup.

♦️ **Queryables** - Queryables allow you to trigger a view presentation with a simple `async` function call that suspends until the presentation has concluded and produced a result. For example, you can trigger a "deletion confirmation" alert and `await` its result with one call, without ever leaving the scope.

♦️ **Signals** - In SwiftUI, you can send data from a child view to a parent view through the use of closures, which are one-time events that trigger an action. Puddles provides a `Signal` type that does the exact same thing, but in the other direction. It lets you send data down the view hierarchy, without forcing a permanent new state. This is highly useful for deep linking and state restoration, where you just want to signify a needed state change from outside a view, without locking any new state from the parent.

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

SwiftUI encourages building views from the ground up, constructing increasingly complex UI by wrapping views in other views. With Puddles, you do the exact same thing, but also include data dependencies in the layering.

![Architecture Overview](https://user-images.githubusercontent.com/7083109/224485578-9f8ee043-a56d-4221-8183-b6ca60cd0135.png)

Starting from the base view that describes the UI of a screen or component, you add a wrapper view that provides and manages the view's state. This wrapper essentially subsumes the tasks of a traditional view model with the key distinction that it is still a view itself, meaning it has access to the full suite of features that the SwiftUI environment provides. 

You would then have additional wrapper views that add data dependencies – like a backend or database – which the views in the layers beneath can access. This keeps all the layers really modular. You can switch out a backend dependency without the underlying views ever knowing or caring about it.

Let's have a look at the individual layers and their respective purpose.

## The View

![View Explanation](https://user-images.githubusercontent.com/7083109/224484750-8aae5d3d-9c4b-4e26-955d-b95c0ccd2ea1.png)

The view is at the base of the architecture. It contains a traditional SwiftUI `body` and behaves just like any other SwiftUI view. However, these views should not own any kind of state. Instead, all required data needed to display itself, should be passed in as a read-only property through a `ViewState` struct. Also, any user interaction should be communicated upstream through an `Interface`, which is a lightweight mechanism to send actions to a parent view, like `Action.didTapButton` for a button tap.

```swift
struct HomeView: View {
  var interface: Interface<Action>
  var state: ViewState
    
  var body: some View {
    VStack {
      Text("Hello, \(state.username)!")
      Button("Tap Me") {
        interface.fire(.didTapButton)
      }
      if let message = state.secretMessage {
        Text(message)
      }
    }
  }
}

extension HomeView {
  struct ViewState {
    var username: String
    var secretMessage: String?
  }
  enum Action {
    case didTapButton
  }
}
```

This setup for the view prevents it from ever modifying its own state in any way. That is by design. Puddles is designed around the notion of _unidirectional data flow_. Everything the view does is sending actions to its parent view, whose task it is to decide in what way the state should change and what side effects need to be triggered. This frees the view of any kind of context or responsibility, making it reusable and highly modular. It is literally just the description of your UI and that's it.

## The View Provider

![View Provider Explanation](https://user-images.githubusercontent.com/7083109/224484721-07a7c5d3-5cb9-4804-8911-442bf6ce0214.png)

The View Provider is the owner of a view's state and takes full responsibility of its data management. Effectively, this is the view's view model but instead of it being defined *inside* the view, it is defined *around* it. That's possible because a View Provider is just another SwiftUI view itself. 

Not only does this free the view from any kind of context – making it highly modular – it also means that the View Provider has access to all the amazing features SwiftUI has to offer, like the environment. 

Moreover, we also gain better control over the encapsulation of the view's data. With traditional view models, all of the state properties – marked with `@Published` – have to have a public getter and often a public setter as well (for access to bindings). This exposes everything and makes it unclear who is actually responsible for managing the state, since technically anyone can read and write to it. As mentioned above, Puddles is all about unidirectional data flow which means it should always be clear where information is coming from and where it is going. And that is exactly what View Providers give us. They are not defined laterally, but rather vertically, keeping a clear and concise flow of information both upstream *and* downstream.

```swift
struct Home: Provider {
  // The view provider can have its own interface to send information upstream
  var interface: Interface<Action>

  // If the view provider depends on external data, it is just declared as a property that is passed in from a parent view
  var username: String
  
  // Here, we store some of the view's non-dependent data
  @State private var secretMessage: String?

  var entryView: some View {
    HomeView(
      interface: .consume(handleViewInterface), // We consume the view's interface and handle incoming actions
      state: .init(
        username: username,
        secretMessage: secretMessage
      )
    )
  }

  @MainActor
  private func handleViewInterface(_ action: HomeView.Action) {
    // Here, we react to user interaction and doe whatever needs to be done to the view's state
    switch action {
    case .didTapButton:
      secretMessage = "You tapped that button!"
      interface.fire(.userDidInteractWithButton)
    }
  }
}

extension Home {
    enum Action {
      case userDidInteractWithButton
    }
}
```

## The Data Provider

![Data Provider Explanation](https://user-images.githubusercontent.com/7083109/224484732-bd859271-084d-4f8b-9c06-568998853289.png)

## The Navigator

![Navigator Explanation](https://user-images.githubusercontent.com/7083109/224484737-5e204683-69cd-43f1-ac0c-4dfaff8c38c3.png)

> **Note**:
> All of the above given rules should be considered to be _leninent guidelines_ that can be broken or circumvented if needed. If it makes sense to have actual bindings, or pass in a dependency in some cases, then do it. Though you might lose some convenience functionality for the SwiftUI Previews, the architecture does support it.

---

## Should you use Puddles?

Finding a solid foundation to build well-structured apps based on the SwiftUI lifecycle has been a challenging problem since the framework's release. While SwiftUI excels at fast paced composition of view hierarchies, it is surprisingly easy to create lots of hard couplings between logic and UI, making it virtually impossible to keep a project modular and flexible. 

Navigation and data management in particular have been troublesome. Both should not be part of UI code since a view is supposed to be agnostic of its context. However, moving the logic too far away means losing out on all the great features that SwiftUI has to offer, like the `Environment` or automatic lifetime management of data. Puddles strives to strike a balance.

Puddles is trying to be as flexible and dynamic as possible. Every app is unique and requires specific ways of doing things, and being locked into a very strict architecture can quickly become frustrating. 

Puddles attempts to offer a helpful guidance and structure for your app, but does not force you into anything. It is built to be fully compatible with any other SwiftUI project, allowing you to incrementally adopt Puddles in existing projects, as well as link to any traditional SwiftUI view from within the scope of a Puddle `Provider` or `Navigator`.

### Why not to use Puddles

**Puddles is not battle-tested (yet)**

Puddles is still a new framework and things might change a lot. You will likely find yourself refactoring your code often, should you decide to use Puddles. Hopefully, this will improve over time as more and more projects are built with this architecture.

**No proper support for unit testing (yet)**

One of the major shortcomings right now is the lack of proper support for unit testing. If you need that, Puddles is not the right choice for now. I will look into it once the rest of the framework has stabilized.

## Frequently Asked Questions

**Q: Do `ObservableObjects` still have a place in this architecture?**<br>
Absolutely! TODO

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
