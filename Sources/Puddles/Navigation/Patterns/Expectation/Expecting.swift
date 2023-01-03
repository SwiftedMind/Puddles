import SwiftUI

/// A navigation wrapper using an ``Expectation`` to retrieve delayed asynchronous data from a contained presentation. See ``Expectation`` for more information.
public struct Expecting<ExpectedType, Destination: NavigationPattern>: NavigationPattern {

    /// A binding to the ``Expectation`` that drives this wrapper.
    @Binding var expectation: Expectation<ExpectedType>

    /// A closure that is given an `isActive` binding as well as a resolver for the expectation and returns a navigation pattern, like ``Alert`` or ``Sheet``.
    @ViewBuilder var destination: (_ isActive: Binding<Bool>, _ expectation: Expectation<ExpectedType>.Resolver) -> Destination

    /// A navigation wrapper using an ``Expectation`` to retrieve delayed asynchronous data from a contained presentation. See ``Expectation`` for more information.
    public init(
        _ expectation: Binding<Expectation<ExpectedType>>,
        @ViewBuilder destination: @escaping (_ isActive: Binding<Bool>, _ expectation: Expectation<ExpectedType>.Resolver) -> Destination
    ) {
        self._expectation = expectation
        self.destination = destination
    }
}

extension Expecting {
    public var body: some View {
        destination($expectation.isActive, expectation.resolver)
            .onChange(of: expectation.isActive) { isActive in
                if isActive { return }
                if let resultOnUserCancel = expectation.resultOnUserCancel {
                    expectation.complete(with: resultOnUserCancel)
                } else {
                    Task {
                        if await expectation.hasContinuation {
                            fatalError("Expectation has been left unfulfilled despite the presentation having ended. Consider initializing the Expectation with `Expectation.userCancellable(resultOnUserCancel)` to provide a result for this case.")
                        }
                    }
                }
            }
    }
}
