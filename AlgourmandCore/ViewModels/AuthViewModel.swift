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
    @Published public var currentProfile: UserProfile?
    @Published public var isAuthenticated: Bool = false
    @Published public var hasCompletedProfile: Bool = true
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var successMessage: String?

    // MARK: - Profile State Storage
    private let profileCompletedKeyPrefix = "algourmand_has_completed_profile_"
    private let localProfileStorage: LocalProfileStorage
    private let localUserStorage: LocalUserStorage

    // MARK: - Configuration
    public let activeMode: ServiceMode
    private let mockService: MockAuthService
    private let apiService: APIAuthService
    private let activeService: AuthServiceProtocol

    // MARK: - Initialization
    public init(
        mode: ServiceMode = .mock,
        mockService: MockAuthService = .shared,
        apiService: APIAuthService = APIAuthService(),
        localProfileStorage: LocalProfileStorage = .shared,
        localUserStorage: LocalUserStorage = .shared
    ) {
        self.activeMode = mode
        self.mockService = mockService
        self.apiService = apiService
        self.activeService = (mode == .mock) ? mockService : apiService
        self.localProfileStorage = localProfileStorage
        self.localUserStorage = localUserStorage

        restorePersistedSession()
    }

    // MARK: - Session Restoration
    public func restorePersistedSession() {
        guard let token = KeychainHelper.readToken() else { return }

        activeService.setToken(token)

        if let savedUser = localUserStorage.loadCurrentUser() {
            self.currentUser = savedUser
            self.isAuthenticated = true

            if let profile = localProfileStorage.loadProfile(for: savedUser.id) {
                self.currentProfile = profile
                self.hasCompletedProfile = true
            } else {
                let isCompleted = isProfileCompleted(for: savedUser.id) || savedUser.email == "quentin@algourmand.ch"
                self.hasCompletedProfile = isCompleted
            }

            Task {
                await refreshCurrentUser()
            }
        }
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

            KeychainHelper.saveToken(response.token)
            localUserStorage.saveCurrentUser(response.user)

            if let profile = localProfileStorage.loadProfile(for: response.user.id) {
                self.currentProfile = profile
                self.hasCompletedProfile = true
            } else {
                let hasCompleted = isProfileCompleted(for: response.user.id) || response.user.email == "quentin@algourmand.ch"
                self.hasCompletedProfile = hasCompleted
            }
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
            self.currentProfile = nil
            self.isAuthenticated = true

            KeychainHelper.saveToken(response.token)
            localUserStorage.saveCurrentUser(response.user)

            UserDefaults.standard.set(false, forKey: "\(profileCompletedKeyPrefix)\(response.user.id.uuidString)")
            self.hasCompletedProfile = false
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
        } catch {
            self.errorMessage = error.localizedDescription
        }

        KeychainHelper.deleteToken()
        localUserStorage.clearCurrentUser()

        self.currentUser = nil
        self.currentProfile = nil
        self.isAuthenticated = false
        self.hasCompletedProfile = true
        self.successMessage = nil

        isLoading = false
    }

    // MARK: - Profile Completion State
    public func isProfileCompleted(for userId: UUID) -> Bool {
        if localProfileStorage.loadProfile(for: userId) != nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "\(profileCompletedKeyPrefix)\(userId.uuidString)")
    }

    public func saveCompletedProfile(_ profile: UserProfile) {
        self.currentProfile = profile
        localProfileStorage.saveProfile(profile, for: profile.id)
        if let user = currentUser {
            localProfileStorage.saveProfile(profile, for: user.id)
            UserDefaults.standard.set(true, forKey: "\(profileCompletedKeyPrefix)\(user.id.uuidString)")
        }
        self.hasCompletedProfile = true
    }

    public func markProfileCompleted() {
        if let user = currentUser {
            UserDefaults.standard.set(true, forKey: "\(profileCompletedKeyPrefix)\(user.id.uuidString)")
        }
        self.hasCompletedProfile = true
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
            localUserStorage.saveCurrentUser(user)
        } catch {
            if let apiError = error as? APIErrorResponse, apiError.message == "Unauthenticated." {
                self.isAuthenticated = false
                self.currentUser = nil
                KeychainHelper.deleteToken()
                localUserStorage.clearCurrentUser()
            }
        }

        isLoading = false
    }
}
