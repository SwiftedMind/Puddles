import SwiftUI

// MARK: - Push isActive

/// A view that controls a navigation presentation.
public struct Push<Destination: View>: NavigationPattern {
    @Binding var isActive: Bool
    @ViewBuilder var destination: () -> Destination

    public init(
        isActive: Binding<Bool>,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self._isActive = isActive
        self.destination = destination
    }
}

public extension Push {
    var body: some View {
        NavigationLink(
            isActive: $isActive) {
                destination()
            } label: {}
    }
}

// MARK: - Push item

/// A view that controls a navigation presentation and is driven by the existence of an item you provide.
public struct PushItem<Item: Identifiable, Destination: View>: NavigationPattern {
    @Binding var item: Item?
    @ViewBuilder var destination: (Item) -> Destination

    public init(
        _ item: Binding<Item?>,
        @ViewBuilder destination: @escaping (Item) -> Destination
    ) {
        self._item = item
        self.destination = destination
    }
}

public extension PushItem {
    var body: some View {
        NavigationLink(isActive: $item.mappedToBool()) {
            if let item {
                destination(item)
            } else {
                Color.red
            }
        } label: {}
    }
}

// MARK: - Helper

extension Binding where Value == Bool {
    init<Wrapped>(bindingOptional: Binding<Wrapped?>) {
        self.init(
            get: {
                bindingOptional.wrappedValue != nil
            },
            set: { newValue in
                guard newValue == false else { return }
                bindingOptional.wrappedValue = nil
            }
        )
    }
}

extension Binding {
    func mappedToBool<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        return Binding<Bool>(bindingOptional: self)
    }
}
