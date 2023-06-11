
<p align="center">
  <img width="200" height="200" src="https://user-images.githubusercontent.com/7083109/231764991-1de9f379-2f2a-41e4-b396-d7592508b6ed.png">
</p>

# A Native SwiftUI Architecture
![GitHub release (latest by date)](https://img.shields.io/github/v/release/SwiftedMind/Puddles?label=Latest%20Release)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftedMind%2FPuddles%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/SwiftedMind/Puddles)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftedMind%2FPuddles%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/SwiftedMind/Puddles)
![GitHub](https://img.shields.io/github/license/SwiftedMind/Puddles)

![Define dependencies, inject them into observable data providers, build your generic UI components and integrate everything into the screens of your app](https://github.com/SwiftedMind/Puddles/assets/7083109/02720cd6-170b-4027-be4f-f406449dffe2)

Puddles is an app architecture for apps built on the SwiftUI lifecycle. It tries to encourage building flexible, modular and scalable apps by providing a set of simple tools and patterns that make development easier and more convenient. 

- **Native** - Powered by what SwiftUI has to offer, extending only what's necessary.
- **Modular** - A project structure that encourages you to build reusable components inside a very flexible app.
- **Composable** - Naturally nest components to build increasingly complex apps, just like SwiftUI intends.
- **Mockable** - A setup that makes mocking data easy, unleashing the power of previews and more.
- **Adoptable** - Designed to work in every project, partially or fully. No huge commitment, easy to opt out.
- **Lightweight** - Small Swift package companion, building on native mechanisms that SwiftUI provides.

## Content

- [Installation](#installation)
- [Documentation](#documentation)
- **[The Puddles Architecture](#the-puddles-architecture)**
- [Examples](#examples)
- **[Should you use Puddles?](#should-you-use-puddles)**
- [License](#license)

## Installation

Puddles supports iOS 15+, macOS 12+, watchOS 8+ and tvOS 15+.

### Swift Package

Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/SwiftedMind/Puddles", from: "1.0.0")
```

### Xcode project

Go to `File` > `Add Packages...` and enter the URL "https://github.com/SwiftedMind/Puddles" into the search field at the top right. Puddles should appear in the list. Select it and click "Add Package" in the bottom right.

## Documentation

The documentation for Puddles can be found here:
[Documentation](https://swiftedmind.github.io/Puddles/documentation/puddles/)


## The Puddles Architecture

### Dependencies
Dependencies are for everything that is not directly related to the UI of your app, like _models_, _networking_,_storage_,  _helpful extensions_ and more.

- **Isolated in a Swift package**
You should define your dependencies in a local Swift package, to make sure the types defined there do not depend on the app.

- **One target per dependency**
Each dependency should be inside its own target, allowing consice imports in the app.

### Providers

Providers act as the connection between the dependencies and the actual app, allowing the app to be entirely agnostic of things like a backend, local storage or other external behavior. They are responsible for fetching, caching and preparing data for the app using one or more dependencies.

- **Mock external data**
Providers don't access the dependencies directly. Rather, they are initialized with a set of closures that provide them with all the external functionality they need. This makes it easy to initialize them with mock data for testing or previewing.

- **Injected into the environment**
Providers are distributed through the native SwiftUI environment, making them easily accessible for every module in the app.

### Views
Providers act as the connection between the dependencies and the actual app, allowing the app to be entirely agnostic of things like a backend, local storage or other external behavior. They are responsible for fetching, caching and preparing data for the app using one or more dependencies.

- **Mock external data**
Providers don't access the dependencies directly. Rather, they are initialized with a set of closures that provide them with all the external functionality they need. This makes it easy to initialize them with mock data for testing or previewing.

- **Injected into the environment**
Providers are distributed through the native SwiftUI environment, making them easily accessible for every module in the app.

### Modules
Modules form the actual structure of the app. They access the providers through the environment and pass the data to the UI components.

- **Modules are SwiftUI views**
To allow access to the environment and other SwiftUI mechanisms as well as to make it easy to place them anywhere, modules are also SwiftUI views.

- **Modules can be nested**
A root module defines the navigational structure of the module, providing a router to submodules Each logical screen inside a navigational hierarchy (think for example  `NavigationStack`) has its own module that can be nested inside a root module

- **Modules are not generic**
TODO

- **Modules define navigation routers**
For each logical view hierarchy of your app,

To get a more in-depth overview of the architecture, have a look at this article: [**The Puddles Architecture**](https://www.swiftedmind.com/blog/posts/introducing-puddles/01_architecture_intro).

## Examples

[**Scrumdinger**](https://github.com/SwiftedMind/Scrumdinger) - Apple's tutorial app re-implemented in Puddles (An awesome idea by the [Pointfree](https://www.pointfree.co/) guys to use Apple's tutorial app to test new ways of building SwiftUI apps).

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
