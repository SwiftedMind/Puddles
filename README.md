
<p align="center">
  <img width="200" height="200" src="https://user-images.githubusercontent.com/7083109/231764991-1de9f379-2f2a-41e4-b396-d7592508b6ed.png">
</p>


# A Native SwiftUI Architecture
![GitHub release (latest by date)](https://img.shields.io/github/v/release/SwiftedMind/Puddles?label=Latest%20Release)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftedMind%2FPuddles%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/SwiftedMind/Puddles)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftedMind%2FPuddles%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/SwiftedMind/Puddles)
![GitHub](https://img.shields.io/github/license/SwiftedMind/Puddles)

![Define dependencies, inject them into observable data providers, build your generic UI components and integrate everything into the screens of your app](https://github.com/SwiftedMind/Puddles/assets/7083109/8169d9f0-c8ed-469c-b191-2894f890d9b3)


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

Puddles separates your project into 4 distinct layers.

### ♦︎ The Core

The _Core_ layer forms the backbone of Puddles. It is implemented as a local Swift package that contains the app's entire business logic in the form of (mostly) isolated data components, divided into individual targets. Everything that is not directly related to the UI belongs in here, encouraging building modular types that are easily and independently modifiable and replaceable.

The app's data models are also defined inside this package, so that each feature component can use and expose _them_, instead of leaking implementation details in the form of DTO objects or something similar. 

The app should be able to consume everything in a way that, for example, makes swapping a local database for a backend as easy as possible.<

```swift
let package = Package(
    name: "Core",
    dependencies: [/* ... */],
    products: [/* ... */],
    targets: [
        .target(name: "Models"), // App Models
        .target(name: "Extensions"), // Useful extensions and helpers
        .target(name: "MockData"), // Mock data 
        .target(name: "BackendConnector", dependencies: ["Models"]), // Connects to a backend
        .target(name: "LocalStore", dependencies: ["Models"]), // Manages a local database
        .target(name: "CultureMinds", dependencies: ["MockData"]), // Data Provider for Iain Banks's Culture book universe
        .target(name: "NumbersAPI", dependencies: ["MockData", "Get"]) // API connector for numbersAPI.com
    ]
)
```

#### Example
Here is a simple class defined in the `NumbersAPI` target, whose sole purpose it is to provide an interface for the app to access random facts about numbers from [NumbersAPI](http://numbersapi.com).

```swift
import Get

public final class Numbers {
    private let client: APIClient
    public init() {/* ... */}
    public func factAboutNumber(_ number: Int) async throws -> String {
        let request = Request<String>(path: "/\(number)")
        return try await client.send(request).value
    }
}
```


### ♦︎ Providers

Views in Puddles never access any of the Core's components directly. Rather, they do so through  _Providers_. They are observable objects distributed through the SwiftUI environment. Their purpose is to provide the app with a stable API that fully hides any kinds of implementation details, allowing us to freely inject mock data into any part of the view hierarchy.

#### Example

Here is a Provider that allows the app to access random facts about numbers. Important to note is the `Dependencies` struct that is passed on initialization. This allows us to initialize the Provider with mock data, in addition to the live data fetched from an API:

```swift
@MainActor final class NumberFactProvider: ObservableObject {
    struct Dependencies {
        var factAboutNumber: (_ number: Int) async throws -> String
    }
    private let dependencies: Dependencies
    init(dependencies: Dependencies) {/* ... */
    func factAboutNumber(_ number: Int) async throws -> String {/* ... */}
}
```

With this, we can define a mock and a live variant of the Provider:

```swift
// MARK: - Inject Live Data
extension NumberFactProvider {
    static var mock: NumberFactProvider = {/* ... */}()
    static var live: NumberFactProvider = {
        let numbers = Numbers() // From the Core Swift package
        return .init(
            dependencies: .init(factAboutNumber: { number in
                try await numbers.factAboutNumber(number)
            })
        )
    }()
}
```

And finally, we can inject the Providers into the environment so that the entire app can easily access them, while still making it possible to override them for specific parts of the view hierarchy.

```swift
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            Root() // App's entry view
                .environmentObject(NumberFactProvider.live)
                /* Other Providers ... */
        }
    }
}
```

Additionally, it is now easy to mock any view by simply giving it a set of mock Providers:

```swift
struct Root_Previews: PreviewProvider {
    static var previews: some View {
        Root().withMockProviders()
    }
}
```


### ♦︎ Views
Providers act as the connection between the dependencies and the actual app, allowing the app to be entirely agnostic of things like a backend, local storage or other external behavior. They are responsible for fetching, caching and preparing data for the app using one or more dependencies.

- **Mock external data** - Providers don't access the dependencies directly. Rather, they are initialized with a set of closures that provide them with all the external functionality they need. This makes it easy to initialize them with mock data for testing or previewing.

- **Injected into the environment** - Providers are distributed through the native SwiftUI environment, making them easily accessible for every module in the app.

### ♦︎ Modules
Modules form the actual structure of the app. They access the providers through the environment and pass the data to the UI components.

- **Modules are SwiftUI views** - To allow access to the environment and other SwiftUI mechanisms as well as to make it easy to place them anywhere, modules are also SwiftUI views.

- **Modules can be nested** - A root module defines the navigational structure of the module, providing a router to submodules Each logical screen inside a navigational hierarchy (think for example  `NavigationStack`) has its own module that can be nested inside a root module

- **Modules are not generic** - TODO

- **Modules define navigation routers** - For each logical view hierarchy of your app,

To get a more in-depth overview of the architecture, have a look at this article: [**The Puddles Architecture**](https://www.swiftedmind.com/blog/posts/introducing-puddles/01_architecture_intro).


## Examples

[**Puddles Examples**](https://github.com/SwiftedMind/Puddles/tree/develop/Examples/PuddlesExamples) - A simple app demonstrating the basic patterns of Puddles.

[**Scrumdinger**](https://github.com/SwiftedMind/Scrumdinger) - Apple's tutorial app re-implemented in Puddles (An awesome idea by the [Pointfree](https://www.pointfree.co/) guys to use Apple's tutorial app to test new ways of building SwiftUI apps).

## Should you use Puddles?

I designed and built Puddles around a few key ideas that fundamentally shaped the architecture with all its advantages, disadvantages and outright problems (I'm looking at you, *lack of unit testing support*).

First and foremost, **I didn't want to over-engineer anything**. While it is certainly possible – and totally valid– to solve a lot of problems and trade-offs by building layers upon layers onto what Swift and SwiftUI already provide, I wanted to stay as close to the native ecosystem as possible to not only allow for more flexibility and freedom, but to also keep everything as lightweight as possible. Right now, you could easily fork the repository and modify or maintain it yourself. It's not much code and most of it should be fairly straightforward. I would like to keep it that way, as much as possible.

Secondly, **I wanted something that's not following the traditional MVVM paradigm**. I know this is highly opinionated and possibly very, very wrong. But strict MVVM as we know it in SwiftUI simply doesn't feel right to me. This might change over time – maybe [SE-0395](https://forums.swift.org/t/se-0395-observability/64342) will help with that in some ways – and the good thing is that it should be relatively easy to pivot Puddles if need be. That's another reason why I designed it to be flexible and lightweight.

TODO!
---
Lastly, I wanted to **explicitly allow views to host their own state**. This makes working with the tools SwiftUI offers much easier.

The flip side of the coin is coupling your UI with your data, which can cause problems. For example, this makes it challenging to restore arbitrary states, which you would need for deep link support – though I do think that I have found a nice solution for that problem via the concept of Target States.

And finally, not separating views from their data source means that unit testing becomes basically impossible, since SwiftUI states only really work in a real SwiftUI environment. However, that might be solvable in the future, when Apple releases or exposes more API to work with.

---

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
