import SwiftUI

// MARK: - Sheet isActive

/// Presents a sheet when a binding to a Boolean value that you provide is true.
public struct Sheet<Destination: View>: NavigationPattern {
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

public extension Sheet {
    var body: some View {
        Color.clear
            .sheet(isPresented: $isActive) {
                destination()
            }
    }
}

// MARK: - Sheet item

///Presents a sheet using the given item as a data source for the sheet’s content.
public struct SheetItem<Item: Identifiable, Destination: View>: NavigationPattern {
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

public extension SheetItem {
    var body: some View {
        Color.clear
            .sheet(item: $item) { item in
                destination(item)
            }
    }
}
