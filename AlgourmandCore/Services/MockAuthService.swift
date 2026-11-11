import Foundation

public final class MockAuthService: AuthServiceProtocol, @unchecked Sendable {
    public static let shared = MockAuthService()

    private let lock = NSLock()
    private var users: [String: (user: UserDTO, password: String)] = [:]
    private var sessionToken: String?
    private var currentSessionUser: UserDTO?

    private var _simulatedDelayNanoseconds: UInt64 = 300_000_000 // 0.3s

    public var simulatedDelayNanoseconds: UInt64 {
        get {
            lock.withLock {
                _simulatedDelayNanoseconds
            }
        }
        set {
            lock.withLock {
                _simulatedDelayNanoseconds = newValue
            }
        }
    }

    public init() {
        // Utilisateur de démonstration pré-configuré
        let defaultUser = UserDTO(id: UUID(), username: "chef_quentin", email: "quentin@algourmand.ch")
        users[defaultUser.email.lowercased()] = (user: defaultUser, password: "password123")
    }

    public var currentToken: String? {
        lock.withLock {
            sessionToken
        }
    }

    public func setToken(_ token: String?) {
        lock.withLock {
            sessionToken = token
        }
    }

    public func register(request: RegisterRequest) async throws -> AuthResponse {
        if simulatedDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        }

        return try lock.withLock {
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

            let newId = UUID()
            let newUser = UserDTO(id: newId, username: request.username, email: normalizedEmail)
            users[normalizedEmail] = (user: newUser, password: request.password)

            let token = "mock-bearer-token-\(UUID().uuidString)"
            self.sessionToken = token
            self.currentSessionUser = newUser

            return AuthResponse(token: token, tokenType: "Bearer", user: newUser)
        }
    }

    public func login(request: LoginRequest) async throws -> AuthResponse {
        if simulatedDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        }

        return try lock.withLock {
            let normalizedEmail = request.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

            guard let entry = users[normalizedEmail], entry.password == request.password else {
                throw APIErrorResponse(message: "Invalid credentials.")
            }

            let token = "mock-bearer-token-\(UUID().uuidString)"
            self.sessionToken = token
            self.currentSessionUser = entry.user

            return AuthResponse(token: token, tokenType: "Bearer", user: entry.user)
        }
    }

    public func logout() async throws {
        if simulatedDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        }

        return try lock.withLock {
            guard sessionToken != nil else {
                throw APIErrorResponse(message: "Unauthenticated.")
            }

            self.sessionToken = nil
            self.currentSessionUser = nil
        }
    }

    public func fetchCurrentUser() async throws -> UserDTO {
        if simulatedDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        }

        return try lock.withLock {
            guard sessionToken != nil, let user = currentSessionUser else {
                throw APIErrorResponse(message: "Unauthenticated.")
            }

            return user
        }
    }

    public func resetState() {
        lock.withLock {
            users.removeAll()
            sessionToken = nil
            currentSessionUser = nil

            let defaultUser = UserDTO(id: UUID(), username: "chef_quentin", email: "quentin@algourmand.ch")
            users[defaultUser.email.lowercased()] = (user: defaultUser, password: "password123")
        }
    }
}
