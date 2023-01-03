# Puddles

An architectural pattern for apps built on the SwiftUI lifecycle. It helps separating navigation and logic from the views.

## Overview

> **_NOTE:_** For more in-depth information and interactive tutorials, open the DocC documentation for this package. 

Modularizing SwiftUI apps in a way that views are agnostic of their navigational context has been a challenging problem since its release. This package is an attempt at a solution.

The idea is to structure the app into modules that are each fully managed by a ``Puddles/Coordinator``, who takes care of data management and navigation, similar but not identical to the traditional `UIKit`-based Coordinator pattern. However, unlike other approaches, for example [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture), `Puddles` is trying to be as flexible and dynamic as possible. Every app is unique and requires specific ways of doing things, and being locked into a very strict architecture can quickly become frustrating. 

`Puddles` attempts to offer a helpful guidance and structure for your app, but does not force you into anything. It is built to be fully compatible with any other SwiftUI project, allowing you to incrementally adopt `Puddles` in existing projects, as well as link to any traditional SwiftUI view from within the scope of a `Puddle` `Coordinator`.

It is also easy to build an entirely new app with `Puddles`. The entire basic setup looks like this:

```swift
import SwiftUI
import Puddles

struct Root: Coordinator {
  var entryView: some View {
    Text("Hello, World")
  }
  
  func navigation() -> some NavigationPattern {
    
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
