import Foundation

// MARK: - User Model
public struct UserDTO: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public let username: String
    public let email: String

    public init(id: UUID, username: String, email: String) {
        self.id = id
        self.username = username
        self.email = email
    }
}

// MARK: - Auth Response
public struct AuthResponse: Codable, Sendable {
    public let token: String
    public let tokenType: String
    public let user: UserDTO

    enum CodingKeys: String, CodingKey {
        case token
        case tokenType = "token_type"
        case user
    }

    public init(token: String, tokenType: String = "Bearer", user: UserDTO) {
        self.token = token
        self.tokenType = tokenType
        self.user = user
    }
}

// MARK: - Register Request
public struct RegisterRequest: Encodable, Sendable {
    public let username: String
    public let email: String
    public let password: String
    public let passwordConfirmation: String

    enum CodingKeys: String, CodingKey {
        case username, email, password
        case passwordConfirmation = "password_confirmation"
    }

    public init(username: String, email: String, password: String, passwordConfirmation: String) {
        self.username = username
        self.email = email
        self.password = password
        self.passwordConfirmation = passwordConfirmation
    }
}

// MARK: - Login Request
public struct LoginRequest: Encodable, Sendable {
    public let email: String
    public let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

// MARK: - API Error Response
public struct APIErrorResponse: Codable, Error, Sendable, LocalizedError {
    public let message: String
    public let errors: [String: [String]]?

    public init(message: String, errors: [String: [String]]? = nil) {
        self.message = message
        self.errors = errors
    }

    public var errorDescription: String? {
        if let errors, !errors.isEmpty {
            let details = errors.values.flatMap { $0 }.joined(separator: "\n")
            return "\(message)\n\(details)"
        }
        return message
    }
}
