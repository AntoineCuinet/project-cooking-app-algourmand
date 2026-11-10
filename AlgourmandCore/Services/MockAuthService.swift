import Foundation

public final class MockAuthService: AuthServiceProtocol, @unchecked Sendable {
    public static let shared = MockAuthService()

    private let lock = NSLock()
    private var users: [String: (user: UserDTO, password: String)] = [:]
    private var sessionToken: String?
    private var currentSessionUser: UserDTO?

    public var simulatedDelayNanoseconds: UInt64 = 300_000_000 // 0.3s

    public init() {
        // Utilisateur de démonstration pré-configuré
        let defaultUser = UserDTO(id: 1, username: "chef_quentin", email: "quentin@algourmand.ch")
        users[defaultUser.email.lowercased()] = (user: defaultUser, password: "password123")
    }

    public var currentToken: String? {
        lock.lock()
        defer { lock.unlock() }
        return sessionToken
    }

    public func register(request: RegisterRequest) async throws -> AuthResponse {
        if simulatedDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        }

        lock.lock()
        defer { lock.unlock() }

        let normalizedEmail = request.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if users[normalizedEmail] != nil {
            throw APIErrorResponse(
                message: "The email has already been taken.",
                errors: ["email": ["The email has already been taken."]]
            )
        }

        if request.password != request.passwordConfirmation {
            throw APIErrorResponse(
                message: "The password confirmation does not match.",
                errors: ["password": ["The password confirmation does not match."]]
            )
        }

        let newId = (users.values.map(\.user.id).max() ?? 0) + 1
        let newUser = UserDTO(id: newId, username: request.username, email: normalizedEmail)
        users[normalizedEmail] = (user: newUser, password: request.password)

        let token = "mock-bearer-token-\(UUID().uuidString)"
        self.sessionToken = token
        self.currentSessionUser = newUser

        return AuthResponse(token: token, tokenType: "Bearer", user: newUser)
    }

    public func login(request: LoginRequest) async throws -> AuthResponse {
        if simulatedDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        }

        lock.lock()
        defer { lock.unlock() }

        let normalizedEmail = request.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard let entry = users[normalizedEmail], entry.password == request.password else {
            throw APIErrorResponse(message: "Invalid credentials.")
        }

        let token = "mock-bearer-token-\(UUID().uuidString)"
        self.sessionToken = token
        self.currentSessionUser = entry.user

        return AuthResponse(token: token, tokenType: "Bearer", user: entry.user)
    }

    public func logout() async throws {
        if simulatedDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        }

        lock.lock()
        defer { lock.unlock() }

        guard sessionToken != nil else {
            throw APIErrorResponse(message: "Unauthenticated.")
        }

        self.sessionToken = nil
        self.currentSessionUser = nil
    }

    public func fetchCurrentUser() async throws -> UserDTO {
        if simulatedDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        }

        lock.lock()
        defer { lock.unlock() }

        guard sessionToken != nil, let user = currentSessionUser else {
            throw APIErrorResponse(message: "Unauthenticated.")
        }

        return user
    }

    public func resetState() {
        lock.lock()
        defer { lock.unlock() }
        users.removeAll()
        sessionToken = nil
        currentSessionUser = nil

        let defaultUser = UserDTO(id: 1, username: "chef_quentin", email: "quentin@algourmand.ch")
        users[defaultUser.email.lowercased()] = (user: defaultUser, password: "password123")
    }
}
