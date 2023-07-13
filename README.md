
<p align="center">
  <img width="200" height="200" src="https://user-images.githubusercontent.com/7083109/231764991-1de9f379-2f2a-41e4-b396-d7592508b6ed.png">
</p>


# A Native SwiftUI Architecture
![GitHub release (latest by date)](https://img.shields.io/github/v/release/SwiftedMind/Puddles?label=Latest%20Release)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftedMind%2FPuddles%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/SwiftedMind/Puddles)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftedMind%2FPuddles%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/SwiftedMind/Puddles)
![GitHub](https://img.shields.io/github/license/SwiftedMind/Puddles)

![Define dependencies, inject them into observable data providers, build your generic UI components and integrate everything into the screens of your app](https://github.com/SwiftedMind/Puddles/assets/7083109/cbc93859-932f-4005-a16b-49b4f6a6aa2a)

Puddles is an app architecture for apps built on the SwiftUI lifecycle. It tries to encourage building native, modular and composable apps by providing a set of simple tools and patterns that make development easier and more convenient. 

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

Puddles separates your project into 4 distinct layers. The **Core** defines the app's business logic, the **Providers** distribute a stable API to that logic through the SwiftUI environment, the **Components** define a set of generic, reusable views and the **Modules** glue everything together to form and present the actual screens of the app.

### ♦︎ The Core

The _Core_ layer forms the backbone of Puddles. It is implemented as a local Swift package that contains the app's entire business logic in the form of (mostly) isolated data components, divided into individual targets. Everything that is not directly related to the UI belongs in here, encouraging building modular types that are easily and independently modifiable and replaceable.

The app's data models are also defined inside this package, so that each feature component can use and expose _them_, instead of leaking implementation details in the form of DTO objects or something similar. 

The app should be able to consume everything in a way that, for example, makes swapping a local database for a backend as easy as possible.

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


### ♦︎ Components

The Components layer is made up of generic SwiftUI views that should be as primitive and compact as possible. Ideally, they never access external data from the environment - except for "native" information like `dynamicTypeSize` or `isEnabled` - or contain any kind of contextual implementation that specifies their place and position in the app. You should think of them as small, flexible building blocks that are only pieced together inside the Module layer, which creates the actual screens of the app using those blocks (see the explanation below).

View components can communicate user interactions to their parent (which is usually a Module) via any number of means but Puddles comes with a nice little helper type called `Interface<Action>` that lets you send actions defined in an enum upstream:

```swift
struct MyModule: View {
    var body: some View {
        MyView(interface: .consume({ action in
            switch action {
            case .didTap: print("Did Tap!")
            }
        }))
    }
}
struct MyView: View {
    var interface: Interface<Action>
    var body: some View {
        Button("Tap Me") { interface.send(.didTap) }
    }

    enum Action {
        case didTap
    }
}
```

#### Example

Here is an example of a simple view component as well as an interactive preview of it:

```swift
struct NumberFactView: View {
    var numberFact: NumberFact // The view needs a single model to display itself
    var body: some View {/* ... */}
}

// MARK: - Preview
private struct PreviewState {
    var numberFact: NumberFact = .init(number: 5, content: Mock.factAboutNumber(5))
}

struct NumberFactView_Previews: PreviewProvider {
    static var previews: some View {
        StateHosting(PreviewState()) { $state in // Binding to the preview state
            List {
                NumberFactView(numberFact: state.numberFact)
                Section {/* Debug Controls ... */}
            }
        }
    }
}
```

### ♦︎ Modules

Just like the view components, Modules are plain old SwiftUI views but with a different semantic applied. They take the components and piece them together, providing structure, context and data from the Providers, to form the actual screens of the app.

It is important to understand that Modules themselves are not components, they are not generic at all. They know about their specific place and context in the app, like navigation and view hierarchies. It's inside these Modules where you usually implement things like `List`, `NavigationStack`, `.navigationTitle` or `.toolbar` because those define whole screens, as opposed to only parts of it.

While not necessarily always the case, you can assume that each screen of your app corresponds to some Module.

#### Example
Here's a simple module showing a list with a button and a list. Tapping the button generates a random number and fetches a random fact about it.

```swift
struct NumberModule: View {
    @EnvironmentObject var numberFactProvider: NumberFactProvider // Access to the number fact provider from the environment
    @State private var numberFacts: [NumberFact] = [] // Local state to store fetched data

    var body: some View {
        List {
            Button("Add Random Number Fact") { addRandomFact() }
            Section {
                ForEach(numberFacts) { fact in
                    NumberFactView(numberFact: fact)
               }
            }
        }
    }

    private func addRandomFact() {
        Task {
            let number = Int.random(in: 0...100)
            try await numberFacts.append(.init(number: number, content: numberFactProvider.factAboutNumber(number)))
        }
    }
}
```

## Example Apps

[**Puddles Examples**](https://github.com/SwiftedMind/Puddles/tree/develop/Examples/PuddlesExamples) - A simple app demonstrating the basic patterns of Puddles, including a globally shared Router for navigation.

[**Scrumdinger**](https://github.com/SwiftedMind/Scrumdinger) - Apple's tutorial app re-implemented in Puddles (An awesome idea by the [Pointfree](https://www.pointfree.co/) guys to use Apple's tutorial app to test new ways of building SwiftUI apps).

## Should you use Puddles?

I designed and built Puddles around a few key ideas that fundamentally shaped the architecture with all its advantages, disadvantages.

1.  There should only be  **minimal commitment**  to use Puddles. It has to be easy to integrate into existing projects and just as easy to remove if it doesn't work out.
2.  It should  **never restrain you**. It has to be possible to deviate from the given patterns and techniques.
3.  It should  **feel like native SwiftUI**  with as little abstraction as possible.
4.  It should be  **mockable and previewable**  without effort, throughout every part of the app.

It is possible to find the (subjective) perfect solution for each and every one of these ideas. But it is surprisingly hard to find one that satisfies _all of them_. Puddles is my attempt at finding a compromise, suggesting an architecture as close to my personal ideal solution as possible.

I also didn't want to over-engineer anything. While it is certainly possible – and absolutely valid– to solve a lot of problems and trade-offs by building layers upon layers onto what Swift and SwiftUI already provide, I wanted to stay as close to the native ecosystem as possible to not only allow for more flexibility and freedom, but to also keep everything as lightweight as possible. Right now, you could easily fork the repository and modify or maintain it yourself. It's not much code and most of it should be fairly straightforward. I would like to keep it that way, as much as possible.

Another key point in the design of Puddles was that I didn't want to build on the traditional MVVM pattern that has become quite popular with SwiftUI. I know this is highly opinionated, but strict MVVM as we know it in SwiftUI simply doesn't feel right to me. It restricts you in a lot of ways and renders many of the amazing tools that SwiftUI offers almost unusable or at least makes them very tedious to use. Extracting all the view's logic outside the `View` struct feels like working against the framework. My opinion about this might change over time and the good thing is that it should be relatively easy to pivot Puddles if need be. That's another reason why I designed it to be flexible and lightweight.

The way Puddles is designed has a few shortcomings. The most significant one: Unit testing. While you can test the components in the Core package, as well as the implementation of the Providers, it becomes really hard to properly and thoroughly test Modules, since they are SwiftUI views and there's currently no way of accessing a view's state outside the SwiftUI environment.

With all that said, I'd like to answer this section's question by saying: **Maybe. But maybe not.**. Puddles might not be the best way to build your SwiftUI app. You should always consider your needs, constraints and willingness to try something new and possibly risky. If you do decide to give Puddles a try, though, then I genuinely hope you enjoy it and succeed in building a modular and maintainable app - and have fun along the way.

\- Dennis


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
