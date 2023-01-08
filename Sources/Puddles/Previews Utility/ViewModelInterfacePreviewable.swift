import SwiftUI

/// A convenience protocol to allow usage of the simpler initializer for ``Puddles/Preview``.
public protocol InterfacingView where Self: View {
    associatedtype Interface
    associatedtype ViewState
    init(interface: Interface, state: ViewState)
}
