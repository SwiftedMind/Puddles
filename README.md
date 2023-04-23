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

Tutorials can be found here:
[Tutorials](https://swiftedmind.github.io/Puddles/tutorials/puddlestutorials)

## Examples

[**Scrumdinger**](https://github.com/SwiftedMind/Scrumdinger) - Apple's tutorial app re-implemented in Puddles (An awesome idea by the [Pointfree](https://www.pointfree.co/) guys to use Apple's tutorial app to test new ways of building SwiftUI apps).

[**ExploreAI**](https://github.com/SwiftedMind/GPTPlayground) - A simple app testing out some ideas for OpenAI's ChatGPT API (using my [GPTSwift](https://github.com/SwiftedMind/gptswift) framework as an interface)

---

## The Puddles Architecture

![Puddles Architecture](https://user-images.githubusercontent.com/7083109/232222438-ca21b1f8-c87a-4b27-b6f2-05af6aacfc61.png)

To get an overview of the architecture, have a look at this article: [The Puddles Architecture](https://www.swiftedmind.com/blog/posts/introducing-puddles/01_architecture_intro).


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
