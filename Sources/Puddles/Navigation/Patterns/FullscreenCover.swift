import SwiftUI

// MARK: - FullscreenCover isActive

/// Presents a modal view that covers as much of the screen as possible when binding to a Boolean value you provide is true.
public struct FullscreenCover<Destination: View>: NavigationPattern {
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

public extension FullscreenCover {
    var body: some View {
        Color.clear
            .fullScreenCover(isPresented: $isActive) {
                destination()
            }
    }
}

// MARK: - FullscreenCover item

/// Presents a modal view that covers as much of the screen as possible using the binding you provide as a data source for the sheet’s content.
public struct FullscreenCoverItem<Item: Identifiable, Destination: View>: NavigationPattern {
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

public extension FullscreenCoverItem {
    var body: some View {
        Color.clear
            .fullScreenCover(item: $item) { item in
                destination(item)
            }
    }
}
