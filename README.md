![slice1](https://user-images.githubusercontent.com/7083109/221624800-f99ad5a9-b875-4f95-a394-3d326c1e151d.png)

# Puddles - A SwiftUI Architecture
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftedMind%2FPuddles%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/SwiftedMind/Puddles)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftedMind%2FPuddles%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/SwiftedMind/Puddles)
![GitHub](https://img.shields.io/github/license/SwiftedMind/Puddles)

Puddles is an app architecture for apps built on the SwiftUI lifecycle. It tries to encourage building flexible, modular and scalable apps by providing a set of simple tools and patterns that make development easier and more convenient. However, it doesn't try to lock you into anything. Every project is unique and while it should be generally discouraged, it has to be easy to deviate from existing patterns. Puddles has been designed from the start with this thought in mind.

- [Features](#features)
- [Getting Started](#getting-started)
- [Documentation](#documentation)
- [The Puddles Architecture](#the-puddles-architecture)
- [Why use Puddles?](#why-use-puddles)
- [Why not to use Puddles?](#why-not-to-use-puddles)
- [License](#documentation)

## Features

♦️ **_Designed to Feel Native_** - Puddles has been designed from the ground up to fit right in with the existing SwiftUI API. The framework does not use any kind of hack, workaround or SwiftUI internal methods. Everything is built using standard functionality. Many implementations are just convenient wrappers around existing interfaces.

♦️ **_Architecture_** - Though it might be a controversial opinion, I am not convinced that MVVM is the right pattern to use within SwiftUI. You lose a lot of functionality and often have to work against the framework. That's why Puddles' main structures – `Coordinator` and `Navigator` – are just plain old SwiftUI views. They act as a wrapper around your actual UI and handle logic and data management. This allows you to make use of *all* the cool features and techniques SwiftUI provides.

♦️ **_Flexible_** - `Coordinator` and `Navigator` being SwiftUI views has another huge advantage. They can be placed *anywhere* you could place any SwiftUI view, so you are not locked into the architecture. If you need to implement something that doesn't properly fit within the Puddles architecture, simply build it using different techniques and plug it in. **No problem!**

♦️ **_Modular_**- Puddles is designed to encourage highly modular code by layering logic and dependencies in nested `Coordinators`, which can be swapped out easily and even be moved across different projects!

♦️ **_Unidirectional Data Flow_** - While not strictly enforced by the framework, Puddles is designed around one-way communication between components. This greatly reduces complexity while increasing modularity and ease of use in SwiftUI Previews. To do this, Puddles provides an easy to use `Interface` type that lets you send `actions` to an interface observer.

♦️ **_Deep Link Support_** - Support for deep linking and arbitrary state restoration is built-in from the start and does not require much extra work or setup.

♦️ **_Queryables_** - Queryables allow you to trigger a view presentation with a simple `async` function call that suspends until the presentation has concluded and produced a result. For example, you can trigger a "deletion confirmation" alert and `await` its result with one call, without ever leaving the scope.

♦️ **_Signals_** - In SwiftUI, you can send data from a child view to a parent view through the use of closures, which are one-time events that trigger an action. Puddles provides a `Signal` type that does the exact same thing, but in the other direction. It lets you send data down the view hierarchy, without forcing a permanent new state. This is highly useful for deep linking and state restoration, where you just want to signify a needed state change from outside a view, without locking any new state from the parent.

## Getting Started

> **Warning**
> Puddles is still in early development. Things will break, so please use this carefully and at your own risk. Feedback is always appreciated.

### Requirements

Puddles supports iOS 15+ and macOS 12+.

### Installation

You can install Puddles through the Swift Package Manager. Simply add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/SwiftedMind/Puddles", branch: "main")
```

Alternatively, if you want to add the package to an Xcode project, go to `File` > `Add Packages...` and enter the URL "https://github.com/SwiftedMind/Puddles" into the search field at the top right. Puddles should appear in the list. Select it and click "Add Package" in the bottom right.

## Documentation

The documentation for Puddles can be found here:
[Documentation](https://swiftedmind.github.io/Puddles/documentation/puddles/)

Tutorials can be found here:
[Tutorials](https://swiftedmind.github.io/Puddles/tutorials/puddlestutorials)

## The Puddles Architecture

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/7083109/223799527-4de8fd7c-1078-40fc-9fdc-073c3006c753.png">
  <img alt="Text changing depending on mode. Light: 'So light!' Dark: 'So dark!'" src="https://user-images.githubusercontent.com/7083109/223750274-db452fb0-b797-4866-ba46-83c4ee92e5b4.png">
</picture>

### The View

The view is at the core of the architecture. It contains a traditional SwiftUI `body` and behaves just like any other SwiftUI view you've likely built. However, in the Puddles architecture, these views should not own any kind of state. Rather, they should define their own `ViewState`, which is a simple `struct` containing everything the view needs to display itself.

```swift
struct YourView: View {
  var state: ViewState
    
  var body: some View {
    Text(state.message)
  }
}

extension HomeView {
  struct ViewState {
    var message: String
  }
}
```

It is important to note that the `ViewState` is added to the view as a read-only property! _A view should never be able to modify its own state_. As a consequence, you shouldn't use traditional bindings as they 

struct HomeView: View {
  var interface: Interface<Action>
  var state: ViewState
    
  var body: some View {
    VStack {
      Text(state.message)
      TextField("Name:", text: interface.binding(state.name, to: { .didChangeName($0) }))
    }
  }
}

extension HomeView {
  struct ViewState {
    var message: String
  }
  enum Action {
    case didChangeName(String)
  }
}

The reason behind all this is to keep all views absolutely context-free. They should not care about who is displaying them or where they are being displayed in the app. They are purely defined by the values inside of their `ViewState` struct and that's it. Finally, this approach makes using SwiftUI Previews much easier and much more powerful as we will see below.

> **Note**:
> All of the above given rules should be considered to be _leninent guidelines_ that can be broken or circumvented if needed. If it makes sense to have actual bindings, or pass in a dependency in some cases, then do it. The architecture fully supports this.


### The Coordinator

### The Provider

### The Navigator

## Why use Puddles?

Finding a solid foundation to build well-structured apps based on the SwiftUI lifecycle has been a challenging problem since the framework's release. While SwiftUI excels at fast paced composition of view hierarchies, it is surprisingly easy to create lots of hard couplings between logic and UI, making it virtually impossible to keep a project modular and flexible. 

Navigation and data management in particular have been troublesome. Both should not be part of UI code since a view is supposed to be agnostic of its context. However, moving the logic too far away means losing out on all the great features that SwiftUI has to offer, like the `Environment` or automatic lifetime management of data. Puddles strives to strike a balance.

Puddles is trying to be as flexible and dynamic as possible. Every app is unique and requires specific ways of doing things, and being locked into a very strict architecture can quickly become frustrating. 

Puddles attempts to offer a helpful guidance and structure for your app, but does not force you into anything. It is built to be fully compatible with any other SwiftUI project, allowing you to incrementally adopt Puddles in existing projects, as well as link to any traditional SwiftUI view from within the scope of a Puddle `Coordinator` or `Navigator`.

## Why not to use Puddles?

Puddles is still in early development and things will break regularly. Also, one of the major shortcomings right now is the lack of proper support for unit testing. If you need that, Puddles is not the right choice for now. I will look into it once the rest of the framework has stabilized.

**Puddles is not battle-tested (yet)**

**SwiftUI Lifecycle**

**No proper support for unit testing (yet)**

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
