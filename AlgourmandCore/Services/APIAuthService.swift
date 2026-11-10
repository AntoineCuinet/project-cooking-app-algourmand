import Foundation

public final class APIAuthService: AuthServiceProtocol, @unchecked Sendable {
    public let baseURL: URL
    private let session: URLSession
    private let lock = NSLock()
    private var tokenStorage: String?

    public init(baseURL: URL = URL(string: "http://127.0.0.1:8000/api/v1")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public var currentToken: String? {
        lock.lock()
        defer { lock.unlock() }
        return tokenStorage
    }

    public func setToken(_ token: String?) {
        lock.lock()
        tokenStorage = token
        lock.unlock()
    }

    public func register(request: RegisterRequest) async throws -> AuthResponse {
        let url = baseURL.appendingPathComponent("register")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await session.data(for: urlRequest)
        let httpResponse = try validateHTTPResponse(response, data: data)

        guard httpResponse.statusCode == 201 else {
            throw try parseError(from: data, statusCode: httpResponse.statusCode)
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        setToken(authResponse.token)
        return authResponse
    }

    public func login(request: LoginRequest) async throws -> AuthResponse {
        let url = baseURL.appendingPathComponent("login")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await session.data(for: urlRequest)
        let httpResponse = try validateHTTPResponse(response, data: data)

        guard httpResponse.statusCode == 200 else {
            throw try parseError(from: data, statusCode: httpResponse.statusCode)
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        setToken(authResponse.token)
        return authResponse
    }

    public func logout() async throws {
        let url = baseURL.appendingPathComponent("logout")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = currentToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: urlRequest)
        let httpResponse = try validateHTTPResponse(response, data: data)

        guard httpResponse.statusCode == 204 else {
            throw try parseError(from: data, statusCode: httpResponse.statusCode)
        }

        setToken(nil)
    }

    public func fetchCurrentUser() async throws -> UserDTO {
        let url = baseURL.appendingPathComponent("user")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = currentToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: urlRequest)
        let httpResponse = try validateHTTPResponse(response, data: data)

        guard httpResponse.statusCode == 200 else {
            throw try parseError(from: data, statusCode: httpResponse.statusCode)
        }

        return try JSONDecoder().decode(UserDTO.self, from: data)
    }

    private func validateHTTPResponse(_ response: URLResponse, data: Data) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIErrorResponse(message: "Invalid HTTP response.")
        }
        return httpResponse
    }

    private func parseError(from data: Data, statusCode: Int) throws -> Error {
        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
            return apiError
        }
        return APIErrorResponse(message: "Request failed with HTTP status \(statusCode).")
    }
}
