# ``Puddles``

A modern and native SwiftUI app architecture

Puddles is an app architecture for apps built on the SwiftUI lifecycle. It tries to encourage building flexible, modular and scalable apps by providing a set of simple tools and patterns that make development easier and more convenient. However, it doesn't try to lock you into anything. Every project is unique and while it should be generally discouraged, it has to be easy to deviate from existing patterns. Puddles has been designed from the start with this thought in mind.

@Image(source: "puddles_banner.png", alt: "A banner of the Puddles logo") 

## Features

➖ **Architecture** - Puddles diverges from strict MVVM in SwiftUI, opting for two main structures called `Provider` and `Navigator`, which are plain SwiftUI views. These structures wrap around your UI to handle logic and data management, while maintaining access to all SwiftUI features and techniques.

➖ **Modular** - Puddles is designed to encourage highly modular code by layering logic and dependencies in nested `Providers`, which can be swapped out easily and even be moved across different projects!

➖ **Flexible** - Since `Provider` and `Navigator` are SwiftUI views, they can be placed anywhere a SwiftUI view can be placed, offering flexibility in architecture. If Puddles' architecture doesn't suit your needs in specific cases, simply use alternative techniques and integrate them seamlessly.

➖ **Designed to Feel Native** - Puddles is built to integrate with SwiftUI API without relying on hacks, workarounds, or internal methods. Many implementations are convenient wrappers around existing interfaces.

➖ **Unidirectional Data Flow** - Puddles is designed for one-way communication between components, reducing complexity and enhancing modularity and ease of use with SwiftUI Previews. It provides an `Interface` type for sending actions to an interface observer.

➖ **Deep Link Support** - Puddles includes built-in support for deep linking and arbitrary state restoration with minimal additional setup.

➖ **Queryables** - Queryables enable you to present a view and `await` its completion with a single async function call that automatically takes care of setting presentation state. This simplifies tasks like triggering a deletion confirmation alert and awaiting its result, all from a single scope.

➖ **Target States** - In SwiftUI, you can send data from a child view to a parent view through the use of closures, which are one-time events that trigger an action. Puddles introduces a `TargetState` concept that lets you send "one-time" data down the view hierarchy without enforcing a new state. This is particularly useful for deep linking and state restoration, allowing state changes from outside a view without locking new states from the parent.

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
- ``Puddles/TargetStateSetter``
