import Combine
import Foundation

@MainActor
public final class AuthViewModel: ObservableObject {
    // MARK: - Service Mode
    public enum ServiceMode: String, CaseIterable, Identifiable {
        case mock = "Mock Local"
        case api = "API Laravel (127.0.0.1:8000)"

        public var id: String { rawValue }
    }

    // MARK: - Published Properties
    @Published public var currentUser: UserDTO?
    @Published public var isAuthenticated: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var successMessage: String?

    // MARK: - Configuration
    public let activeMode: ServiceMode
    private let mockService: MockAuthService
    private let apiService: APIAuthService
    private let activeService: AuthServiceProtocol

    // MARK: - Initialization
    public init(
        mode: ServiceMode = .mock,
        mockService: MockAuthService = .shared,
        apiService: APIAuthService = APIAuthService()
    ) {
        self.activeMode = mode
        self.mockService = mockService
        self.apiService = apiService
        self.activeService = (mode == .mock) ? mockService : apiService
    }

    // MARK: - Authentication Methods
    public func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let response = try await activeService.login(request: LoginRequest(email: email, password: password))
            self.currentUser = response.user
            self.isAuthenticated = true
            self.successMessage = "Connexion réussie !"
        } catch {
            self.errorMessage = error.localizedDescription
            self.isAuthenticated = false
        }

        isLoading = false
    }

    public func register(username: String, email: String, password: String, passwordConfirmation: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let request = RegisterRequest(
                username: username,
                email: email,
                password: password,
                passwordConfirmation: passwordConfirmation
            )
            let response = try await activeService.register(request: request)
            self.currentUser = response.user
            self.isAuthenticated = true
            self.successMessage = "Compte créé et connecté !"
        } catch {
            self.errorMessage = error.localizedDescription
            self.isAuthenticated = false
        }

        isLoading = false
    }

    public func logout() async {
        isLoading = true
        errorMessage = nil

        do {
            try await activeService.logout()
            self.currentUser = nil
            self.isAuthenticated = false
            self.successMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    public func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }

    public func refreshCurrentUser() async {
        guard isAuthenticated else { return }
        isLoading = true
        errorMessage = nil

        do {
            let user = try await activeService.fetchCurrentUser()
            self.currentUser = user
        } catch {
            self.errorMessage = error.localizedDescription
            self.isAuthenticated = false
            self.currentUser = nil
        }

        isLoading = false
    }
}
