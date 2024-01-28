<img width="100" height="100" src="https://user-images.githubusercontent.com/7083109/231764991-1de9f379-2f2a-41e4-b396-d7592508b6ed.png">

# A Native SwiftUI Architecture
![GitHub release (latest by date)](https://img.shields.io/github/v/release/SwiftedMind/Puddles?label=Latest%20Release)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftedMind%2FPuddles%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/SwiftedMind/Puddles)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftedMind%2FPuddles%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/SwiftedMind/Puddles)
![GitHub](https://img.shields.io/github/license/SwiftedMind/Puddles)

![Define dependencies, inject them into observable data providers, build your generic UI components and integrate everything into the screens of your app](https://github.com/SwiftedMind/Puddles/assets/7083109/cbc93859-932f-4005-a16b-49b4f6a6aa2a)

Puddles is an architecture for SwiftUI apps with a focus on using as many native mechanisms and patterns as possible, while only adding abstractions and custom types when absolutely necessary.

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
- [Example Apps](#example-apps)
- **[A Few Words On Puddles](#a-few-words-on-puddles)**
- [License](#license)

## Installation

Puddles supports iOS 15+, macOS 12+, watchOS 8+ and tvOS 15+.

### Swift Package

Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/SwiftedMind/Puddles", from: "2.0.0")
```

### Xcode project

Go to `File` > `Add Packages...` and enter the URL "https://github.com/SwiftedMind/Puddles" into the search field at the top right. Puddles should appear in the list. Select it and click "Add Package" in the bottom right.

## Documentation

The documentation for Puddles can be found here:
[Documentation](https://swiftpackageindex.com/SwiftedMind/Puddles/documentation/puddles)


## The Puddles Architecture

Puddles separates your project into 4 distinct layers, the **Modules**, the **Components**, the **Providers** and the **Core**.

### 》Modules

#### 〉The Structure of the App

Apps in Puddles are made up of Modules, which generally can be thought of as individual screens - for example,  `Home` is a Module responsible for showing the home screen while `NumbersExample` is responsible for a screen showing facts about random numbers. Modules are SwiftUI views, so they can be composed together in a natural and familiar way to form the overall structure of the app.

```swift
/// The Root Module - the entry point of a simple example app.
struct Root: View {

  /// A global router instance that centralizes the app's navigational states for performant and convenient access across the app.
  @ObservedObject var rootRouter = Router.shared.root

  var body: some View {
    Home()
      .sheet(isPresented: $rootRouter.isShowingLogin) {
          Login()
      }
      .sheet(isPresented: $rootRouter.isShowingNumbersExample) {
          NumbersExample()
      }
  }
}
```

#### 〉Composing the User Interface

Modules define the screens and behavior of the app by composing simple, generic components together. They have access to the environment where they can get access to a controlled, abstract interface that drives the app's interaction with external data and other frameworks.

```swift
/// A Module rendering a screen where you can fetch and display facts about random numbers.
struct NumbersExample: View {

  /// A Provider granting access to external data and other business logic around number facts.
  @EnvironmentObject var numberFactProvider: NumberFactProvider

  /// A local state managing the list of already fetched number facts.
  @State private var numberFacts: [NumberFact] = []

  // The Module's body, composing the UI and UX from various generic view components.
  var body: some View {
    NavigationStack {
      List {
        Button("Add Random Number Fact") { addRandomFact() }
        Section {
          ForEach(numberFacts) { fact in
            NumberFactView(numberFact: fact)
          }
        }
      }
      .navigationTitle("Number Facts")
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

#### 〉Modules are not Components

Modules describe the overall structure of the app, so they are not reusable. They have a fixed and predetermined position in the app and can therefore hardwire specific behavioral and navigational actions inside them. You can define multiple Modules in different places of the view hierarchy, that use the same underlying components, but apply different behaviors to them.

```swift
/// A (slightly contrived) example of a Module similar to NumbersExample, rendering a screen where you can shuffle all the number facts provided by a parent module.
struct ShuffleNumbersExample: View {

  /// A list of number facts that can be passed in
  @Binding var numberFacts: [NumberFact] = []

  // The Module's body, composing the UI and UX from various generic view components.
  var body: some View {
    NavigationStack {
      List {
        Button("Shuffle Everything") { shuffleFacts() }
        Section {
          ForEach(numberFacts) { fact in
            NumberFactView(numberFact: fact)
          }
        }
      }
      .navigationTitle("Shuffle Your Facts")
    }
  }

  private func shuffleFacts() {
    numberFacts = numberFacts.shuffled()
  }
}
```

### 》Components

#### 〉Generic SwiftUI views

The Components layer is made up of many small, generic SwiftUI views that, put together, form the UI of your app. They don't own any data or have access to external business logic. Their only purpose is to take pieces of information and describe how they should be displayed.

```swift
/// A simple component that displays a number fact.
struct NumberFactView: View {
  var numberFact: NumberFact // Data model
  var body: some View {
    if let content = numberFact.content {
      VStack(alignment: .leading) {
        Text("Number: \(numberFact.number)")
          .font(.caption)
          .fixedSize()
        Text(content)
          .fixedSize(horizontal: false, vertical: true)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    } else {
      ProgressView()
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
  }
}
```

#### 〉They Are Building Blocks

View components are the fundamental building blocks that naturally cause a powerful modularity by allowing you to combine them in different ways, creating a vast range of possible user interfaces and experiences in the Modules.

#### 〉They Don't Make Assumptions

View components don't make any assumptions about the context in which they are used. Ideally, they are built in a way that makes them reusable in _any_ context, by letting their parent views supply the data and interpretation of user interactions.

#### 〉Build Interactive Previews

Puddles comes with a set of tools that make it easy to add fully interactive previews to your view components.

```swift
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

### 》Providers

#### 〉Control Data Access and Interaction

The Providers drive the app's interaction with external data and other frameworks by exposing a controlled and stable interface to the Modules. This fully hides any implementation details and logic specific to the nature and origin of the provided data, allowing you to swap dependencies without ever touching the Modules relying on them.

```swift
/// Provides access to facts about numbers.
@MainActor final class NumberFactProvider: ObservableObject {
  struct Dependencies {
    var factAboutNumber: (_ number: Int) async throws -> String
  }

  private let dependencies: Dependencies
  init(dependencies: Dependencies) {/* ... */}

  // The views only ever use the public interface and know nothing about the dependencies
  func factAboutNumber(_ number: Int) async throws -> String {
    try await dependencies.factAboutNumber(number)
  }
}
```

#### 〉Inject Dependencies during Initialization

Providers use dependency injection to enable full control over what data the Provider is distributing to the app. You can define variants using real data for the live app and mocked data for testing and previewing purposes.

```swift
extension NumberFactProvider {
  static var mock: NumberFactProvider = {/* Provide mocked data */}()
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

#### 〉Distribute through the SwiftUI Environment

Providers are distributed through the SwiftUI environment, allowing you to inject them at any point in the view hierarchy and even override parts of it with mocked variants .

```swift
struct YourApp: App {
  var body: some Scene {
    WindowGroup {
      Root()
        .environmentObject(NumberFactProvider.live)
    }
  }
}
```

```swift
struct Root: View {
  var body: some View {
    List {
      SectionA() // SectionA will interact with real data
      SectionB()
        .environmentObject(NumberFactProvider.mock) // SectionB will interact with mocked data
    }
  }
}
```

#### 〉Unleash the Power of Previews

This way of working with business logic and external data access allows you to build _fully interactive_ and functional SwiftUI Previews with ease, for every single view in your app, by simply injecting mocked data into the previews provider.

```swift
struct Root_Previews: PreviewProvider {
  static var previews: some View {
    Root().withMockProviders()
  }
}
```


### 》The Core

#### 〉Isolate Business Logic

The Core layer forms the backbone of Puddles. It is implemented as a local Swift package that contains the app's entire business logic in the form of (mostly) isolated components, divided into individual targets. Everything that is not directly related to the UI belongs in here, encouraging building modular types that are easily and independently modifiable and replaceable.

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

#### 〉Connect External Dependencies

Build targets that connect to your backend, local database or any external framework dependency and provide an interface for the app to connect to them.

```swift
import Get // https://github.com/kean/Get

/// Fetches random facts about numbers from https://numbersapi.com
public final class Numbers {
  private let client: APIClient
  public init() {/* ... */}

  public func factAboutNumber(_ number: Int) async throws -> String {
    let request = Request<String>(path: "/\(number)")
    return try await client.send(request).value
  }
}
```

#### 〉Define App Models

The app's data models are also defined inside this package, so that each feature component can use and expose them, instead of leaking implementation details in the form of DTO objects or something similar.

```swift
public struct NumberFact: Identifiable, Equatable {
  public var id: Int { number }
  public var number: Int
  public var content: String?

  public init(number: Int, content: String? = nil) {
    self.number = number
    self.content = content
  }
}
```

### 》Navigation

#### 〉Globally Accessible Router

Since Modules are anchored in a fixed and predetermined location of the app, navigation can be hardwired into them. Therefore, a globally accessible `Router` singleton makes it easy to jump from one place in the app to any other, with a simple call.

```swift
/// The home Module.
struct Home: View {

  var body: some View {
    List {
      Button("Login") {
        // Easy access to a globally shared router
        Router.shared.showLogin()
      }
      Button("Numbers Example") {
        Router.shared.navigate(to: .numbersExample)
      }
    }
  }
}
```

#### 〉Centralized Navigation State

The Router` class is a singleton that is responsible for managing the entire navigation state for every part of the app. That allows it to navigate to any point in the view hierarchy and expose simple and convenient methods for the Modules to do so.

```swift
/// An object that holds the entire navigational state of the app.
@MainActor final class Router {
  static let shared: Router = .init()

  /// An observable object holding all the navigational state of the root Module.
  var root: RootRouter = .init()
  var home: HomeRouter = .init()

  /// An enum that represents all the possible destinations in the app.
  enum Destination: Hashable {
    case root
    case numbersExample
  }

  /// Navigates to a destination.
  func navigate(to destination: Destination) {
    switch destination {
    case .root:
      root.reset()
      home.reset()
    case .numbersExample: // Shows the numbers example after resetting the app's navigation state.
      root.reset()
      home.reset()
      showNumbersExample()
    }
  }

  /// Presents the login modally over the current context.
  func showLogin() {
    root.isShowingLogin = true
  }

  /// Dismisses the login.
  func dismissLogin() {
    root.isShowingLogin = false
  }

  /// Presents the numbers example modally over the current context.
  func showNumbersExample() {
    root.isShowingNumbersExample = true
  }

  /// Dismisses the numbers example.
  func dismissNumbersExample() {
    root.isShowingNumbersExample = false
  }
}
```

#### 〉Observed Only Where Needed

The only place a Router is marked as @ObservedObject is inside the Modules that implement the view modifiers driven by the Router's published state. This way, changing the navigation state will only ever update the Modules that are actually affected by the change.

```swift
/// The Root Module - the entry point of a simple example app.
struct Root: View {

  /// A global router instance that centralizes the app's navigational states for performant and convenient access across the app.
  @ObservedObject var rootRouter = Router.shared.root

  var body: some View {
    Home()
      .sheet(isPresented: $rootRouter.isShowingLogin) {
        Login()
      }
      .sheet(isPresented: $rootRouter.isShowingNumbersExample) {
        NumbersExample()
      }
  }
}
```

---

## Example Apps

[**Puddles Examples**](https://github.com/SwiftedMind/Puddles/tree/main/Examples/PuddlesExamples) - A simple app demonstrating the basic patterns of Puddles, including a globally shared Router for navigation.

## A Few Words On Puddles

I designed and built Puddles around a few key ideas that fundamentally shaped the architecture with all its advantages and disadvantages.

1.  It should take **minimal commitment** to use Puddles. It has to be easy to integrate into existing projects and just as easy to remove if it doesn't work out.
2.  It should **never restrain you**. It has to be possible to deviate from the suggested patterns and techniques.
3.  It should **feel like native SwiftUI** with as little abstraction as possible.
4.  It should be **mockable and previewable** without effort, throughout every part of the app.

It is possible to find the (subjective) perfect solution for each and every one of these ideas. But it is surprisingly hard to find one that satisfies _all of them_. Puddles is my attempt at finding a compromise, suggesting an architecture as close to my personal ideal solution as possible.

I also didn't want to over-engineer anything. While it is certainly possible – and absolutely valid – to solve a lot of problems and trade-offs by building layers upon layers onto what Swift and SwiftUI already provide, I wanted to stay as close to the native ecosystem as possible to not only allow for more flexibility and freedom, but to also keep everything as lightweight as possible. Right now, you could easily fork the repository and modify or maintain it yourself. It's not much code and most of it should be fairly straightforward. I would like to keep it that way, as much as possible.

Another key point in the design of Puddles was that I didn't want to build on the traditional MVVM pattern that has become quite popular with SwiftUI. I know this is highly opinionated, but strict MVVM as we know it in SwiftUI simply doesn't feel right to me. It restricts you in a lot of ways and renders many of the amazing tools that SwiftUI offers almost unusable or at least makes them very tedious to use. Extracting all the view's logic outside the `View` struct feels like working against the framework. My opinion about this might change over time and the good thing is that it should be relatively easy to pivot Puddles if need be. That's another reason why I designed it to be flexible and lightweight.

The way Puddles is designed has a few shortcomings. The most significant one: Unit testing. While you *can* test the components in the Core layer, as well as the implementation of the Providers, it becomes really hard to properly and thoroughly test Modules, since they are SwiftUI views and there's currently no way of accessing a view's state outside the SwiftUI environment. That is a trade-off you have to be willing to accept when deciding to try building an app with Puddles.

With all that said, I'd like to emphasize that **Puddles might not be the best way to build your SwiftUI app** and you might even lightly or strongly dislike it. It is an attempt at coming up with an alternative to traditional MVVM. You should always consider your needs, constraints and willingness to try something new and possibly risky. If you do decide to give Puddles a try, though, then I genuinely hope that you succeed in building a modular and maintainable app - and have fun along the way.

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
