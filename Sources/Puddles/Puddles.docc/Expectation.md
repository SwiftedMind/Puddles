# ``Puddles/Expectation``

## Example

```swift
struct HomeCoordinator: Coordinator {
  @StateObject var interface: MyView.Interface = .init()
  
  @State var deletionConfirmation = Expectation<Bool>.guaranteedCompletion()
  
  var entryView: some View {
    MyView(interface: interface)
  }

  func navigation() -> some NavigationPattern {
    Expecting($deletionConfirmation) { isActive, expectation in
      Alert(
        title: "Do you want to delete this?",
        isPresented: isActive) {
          Button("Cancel", role: .cancel) {
            expectation.complete(with: false)
          }
          Button("OK") {
            expectation.complete(with: true)
          }
        } message: {
          Text("This cannot be reversed!")
        }
    }
  }

  func handleAction(_ action: Action) async {
    switch action {
    case .deleteButtonTapped:
      deletionConfirmation.show()
      let shouldDelete = await deletionConfirmation.result
      if shouldDelete {
        // Delete
      }
      // Alerts automatically hide, so no need to do it here
    }
  }
}
```

## Topics

### Related Types

- ``Puddles/Expecting``
