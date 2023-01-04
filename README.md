
![banner](https://user-images.githubusercontent.com/7083109/210643109-93cccd3f-9d5f-4517-87da-6c2529de0f41.png)

## What is Puddles?

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

The documentation for `Puddles` can be found here:
https://havingthought.github.io/Puddles/documentation/puddles/

Tutorials can be found here:
https://havingthought.github.io/Puddles/tutorials/puddlestutorials

## License

MIT License

Copyright (c) 2023 Dennis Müller

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
