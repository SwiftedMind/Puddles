# ``Puddles``


An architectural pattern for apps built on the SwiftUI lifecycle. It helps separating navigation and logic from the views.

## Overview

Finding a solid foundation to build well-structured apps based on the SwiftUI lifecycle has been a challenging problem since the framework's release. While SwiftUI excels at fast paced composition of view hierarchies, it is surprisingly easy to create lots of hard couplings between logic and UI, making it virtually impossible to keep a project modular and structured. 

Navigation and data management in particular have been troublesome. Both should not be part of UI code since a view is supposed to be agnostic of its context. However, moving the logic too far away means losing out on all the great features that SwiftUI offers, like the `Environment`. `Puddles` strives to strike that balance.

The idea is to structure the app into modules, screens or features, that are each fully managed by a `Coordinator`, who takes care of data management and navigation. However, `Puddles` is trying to be as flexible and dynamic as possible. Every app is unique and requires specific ways of doing things, and being locked into a very strict architecture can quickly become frustrating. 

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

  func interfaces() -> Interfaces {

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

- ``Puddles/Coordinator``
- ``Puddles/ViewInterface``
- ``Puddles/NavigationBuilder``
