import Foundation
import Get

public final class Numbers {

    private let client: APIClient

    public init() {
        self.client = APIClient(baseURL: URL(string: "http://numbersapi.com"))
    }

    public func factAboutRandomNumber() async throws -> String {
        let request = Request<String>(path: "random/trivia")
        return try await client.send(request).value
    }

    public func factAboutNumber(_ number: Int) async throws -> String {
        let request = Request<String>(path: "/\(number)")
        return try await client.send(request).value
    }
}
