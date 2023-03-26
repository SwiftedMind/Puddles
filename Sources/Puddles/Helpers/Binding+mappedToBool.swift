import SwiftUI

extension Binding where Value == Bool {

    @MainActor
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

    @MainActor
    func mappedToBool<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        return Binding<Bool>(bindingOptional: self)
    }
}
