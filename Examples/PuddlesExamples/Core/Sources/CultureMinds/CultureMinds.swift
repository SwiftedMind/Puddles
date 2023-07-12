import Foundation
import MockData

public final class CultureMinds {
    public init() { }

    public func randomName() -> String {
        Mock.cultureMindNames.randomElement()!
    }

    public func allNames() -> [String] {
        Mock.cultureMindNames
    }

    public func generateNames() -> AsyncStream<String> {
        return .init { continuation in
            Task {
                for name in Mock.cultureMindNames.shuffled() {
                    continuation.yield(name)
                    try? await Task.sleep(for: .seconds(1))
                }
                continuation.finish()
            }
        }
    }
}
