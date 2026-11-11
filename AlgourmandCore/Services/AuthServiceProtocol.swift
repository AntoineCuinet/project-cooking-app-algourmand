import Foundation

public protocol AuthServiceProtocol: Sendable {
    var currentToken: String? { get }
    func setToken(_ token: String?)
    func register(request: RegisterRequest) async throws -> AuthResponse
    func login(request: LoginRequest) async throws -> AuthResponse
    func logout() async throws
    func fetchCurrentUser() async throws -> UserDTO
}
