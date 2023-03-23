# ``Puddles``

A modern and native SwiftUI app architecture

Puddles is an app architecture for apps built on the SwiftUI lifecycle. It tries to encourage building flexible, modular and scalable apps by providing a set of simple tools and patterns that make development easier and more convenient. However, it doesn't try to lock you into anything. Every project is unique and while it should be generally discouraged, it has to be easy to deviate from existing patterns. Puddles has been designed from the start with this thought in mind.

@Image(source: "puddles_banner.png", alt: "A banner of the Puddles logo") 

## Features

🕊️ **Designed to Feel Native** - Puddles has been designed from the ground up to fit right in with the existing SwiftUI API. The framework does not use any kind of hack, workaround or SwiftUI internal methods. Everything is built using standard functionality. Many implementations are just convenient wrappers around existing interfaces.

🪙 **Architecture** - Though it might be a controversial opinion, I am not convinced that MVVM is the right pattern to use within SwiftUI. You lose a lot of functionality and often have to work against the framework. That's why Puddles' main structures – `Provider` and `Navigator` – are just plain old SwiftUI views. They act as a wrapper around the views that actually describe your app's UI and handle logic and data management. This allows you to make use of *all* the cool features and techniques SwiftUI provides.

✨ **Flexibility** - `Provider` and `Navigator` being SwiftUI views has another huge advantage. They can be placed *anywhere* you could place any SwiftUI view, so you are not locked into the architecture. If you need to implement something that doesn't properly fit within the Puddles architecture, simply build it using different techniques and plug it in. **No problem!**.

📁 **Modularity** - Puddles is designed to encourage highly modular code by layering logic and dependencies in nested `Providers`, which can be swapped out easily and even be moved across different projects!

♻️ **Unidirectional Data Flow** - While not strictly enforced by the framework, Puddles is designed around one-way communication between components. This greatly reduces complexity while increasing modularity and ease of use in SwiftUI Previews. To do this, Puddles provides an easy to use `Interface` type that lets you send `actions` to an interface observer.

⚓ **Deeplink Support** - Support for deeplinking and arbitrary state restoration is built-in from the start and does not require much extra work or setup.

⁉️ **Queryables** - Queryables allow you to trigger a view presentation with a simple `async` function call that suspends until the presentation has concluded and produced a result. For example, you can trigger a "deletion confirmation" alert and `await` its result with one call, without ever leaving the scope.

🚦 **TargetStates** - In SwiftUI, you can send data from a child view to a parent view through the use of closures, which are one-time events that trigger an action. Puddles provides a `TargetState` type that does the exact same thing, but in the other direction. It lets you send data down the view hierarchy, without forcing a permanent new state. This is highly useful for deeplinking, where you just want to signify a needed state change from outside a view, without locking any new state from the parent.

## First Steps

It is easy to build an app with Puddles. The entire basic setup looks like this:

```swift
import SwiftUI
import Puddles

struct Root: Provider {
  var entryView: some View {
    Text("Hello, World")
  }
}

@main
struct YourApp: App {
  var body: some Scene {
    WindowGroup {
      Root()
    }
  }
}
```

## Topics

### The Puddles Architecture

- <doc:PuddlesTutorials>

### Core Types

- ``Puddles/Provider``
- ``Puddles/Navigator``
- ``Puddles/Queryable``
- ``Puddles/QueryableWithInput``
- ``Puddles/TargetState``
