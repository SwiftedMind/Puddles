<img src="https://user-images.githubusercontent.com/7083109/210643109-93cccd3f-9d5f-4517-87da-6c2529de0f41.png" width="50%">

## What is Puddles?

> **Warning**
> Puddles is still in early development. Things will break, so please use this carefully and at your own risk. Feedback is always appreciated.

Puddles revolves around a `Coordinator` protocol that is used at the root of each component or screen in your app.

A `Coordinator` is itself a SwiftUI view, meaning it can be placed anywhere that any other view could be placed. It also means that SwiftUI takes full responsibility for handling the Coordinator's lifetime and state objects, unless specified otherwise. Inside a `Coordinator`, you define your component's entry view, its navigational paths (navigation links, sheets, alerts, ...) as well as the entry view's state. Through `view interfaces`, the entry view can read that state and communicate user input to the Coordinator, which can then decide on the desired behavior and state changes. This effectively turns the view into a context-unaware piece of UI that can be placed anywhere in your project (or even a different project).

- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [First Steps](#first-steps)
- [Documentation](#documentation)
- [The Puddles Architecture](#the-puddles-architecture)
  - [Coordinators](#coordinators)
  - [Unidirectional Data Flow](#unidirectional-data-flow)
  - [Data Management](#data-management)
- [Why use Puddles?](#why-use-puddles)
- [License](#documentation)

## Getting Started

### Requirements

Puddles supports the following platforms:

- iOS 15+
- macOS 12+

You will also need Swift 5.7 to compile the package.

### Installation

The package is installed through the Swift Package Manager. Simply add the following line to your `Package.swift` dependencies:

```swift
.package(url: "https://github.com/HavingThought/Puddles", from: "0.1.0")
```

Alternatively, if you want to add the package to an Xcode project, go to `File` > `Add Packages...` and enter the URL "https://github.com/HavingThought/Puddles" into the search field at the top. Puddles should appear in the list. Select it and click "Add Package" in the bottom right.

### First Steps

It is easy to build an app with Puddles. The entire basic setup looks like this:

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

## Documentation

The documentation for Puddles can be found here:
https://swiftedmind.github.io/Puddles/documentation/puddles/

Tutorials can be found here:
https://swiftedmind.github.io/Puddles/tutorials/puddlestutorials

## The Puddles Architecture

### Coordinators

Coming soon...

### Unidirectional Data Flow

Coming soon...

### Data Management

Coming soon...

## Why use Puddles?

Finding a solid foundation to build well-structured apps based on the SwiftUI lifecycle has been a challenging problem since the framework's release. While SwiftUI excels at fast paced composition of view hierarchies, it is surprisingly easy to create lots of hard couplings between logic and UI, making it virtually impossible to keep a project modular and flexible. 

Navigation and data management in particular have been troublesome. Both should not be part of UI code since a view is supposed to be agnostic of its context. However, moving the logic too far away means losing out on all the great features that SwiftUI has to offer, like the `Environment` or automatic lifetime management of data. Puddles strives to strike a balance.

Puddles is trying to be as flexible and dynamic as possible. Every app is unique and requires specific ways of doing things, and being locked into a very strict architecture can quickly become frustrating. 

Puddles attempts to offer a helpful guidance and structure for your app, but does not force you into anything. It is built to be fully compatible with any other SwiftUI project, allowing you to incrementally adopt Puddles in existing projects, as well as link to any traditional SwiftUI view from within the scope of a Puddle `Coordinator`.

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
