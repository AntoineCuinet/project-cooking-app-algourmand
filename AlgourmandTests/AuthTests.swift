@testable import AlgourmandCore
import XCTest

final class AuthTests: XCTestCase {
    private var mockService: MockAuthService!

    override func setUp() {
        super.setUp()
        mockService = MockAuthService()
        mockService.simulatedDelayNanoseconds = 0
        mockService.resetState()
    }

    override func tearDown() {
        mockService = nil
        super.tearDown()
    }

    func testMockLoginSuccess() async throws {
        let loginRequest = LoginRequest(email: "quentin@algourmand.ch", password: "password123")
        let response = try await mockService.login(request: loginRequest)

        XCTAssertEqual(response.tokenType, "Bearer")
        XCTAssertFalse(response.token.isEmpty)
        XCTAssertEqual(response.user.email, "quentin@algourmand.ch")
        XCTAssertEqual(response.user.username, "chef_quentin")
        XCTAssertEqual(mockService.currentToken, response.token)
    }

    func testMockLoginInvalidCredentials() async {
        let badRequest = LoginRequest(email: "quentin@algourmand.ch", password: "wrong-password")

        do {
            _ = try await mockService.login(request: badRequest)
            XCTFail("Login should fail when invalid credentials are provided")
        } catch let error as APIErrorResponse {
            XCTAssertEqual(error.message, "Invalid credentials.")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testMockRegisterSuccess() async throws {
        let registerRequest = RegisterRequest(
            username: "nouveau_chef",
            email: "nouveau@algourmand.ch",
            password: "securepassword",
            passwordConfirmation: "securepassword"
        )

        let response = try await mockService.register(request: registerRequest)

        XCTAssertEqual(response.user.username, "nouveau_chef")
        XCTAssertEqual(response.user.email, "nouveau@algourmand.ch")
        XCTAssertFalse(response.token.isEmpty)
    }

    func testMockRegisterDuplicateEmail() async throws {
        let duplicateRequest = RegisterRequest(
            username: "imposteur",
            email: "quentin@algourmand.ch",
            password: "password123",
            passwordConfirmation: "password123"
        )

        do {
            _ = try await mockService.register(request: duplicateRequest)
            XCTFail("Registration should fail when email is already registered")
        } catch let error as APIErrorResponse {
            XCTAssertEqual(error.message, "The email has already been taken.")
            XCTAssertNotNil(error.errors?["email"])
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testMockFetchUserAndLogout() async throws {
        _ = try await mockService.login(request: LoginRequest(email: "quentin@algourmand.ch", password: "password123"))

        let user = try await mockService.fetchCurrentUser()
        XCTAssertEqual(user.username, "chef_quentin")

        try await mockService.logout()
        XCTAssertNil(mockService.currentToken)

        do {
            _ = try await mockService.fetchCurrentUser()
            XCTFail("fetchCurrentUser should fail after logout")
        } catch let error as APIErrorResponse {
            XCTAssertEqual(error.message, "Unauthenticated.")
        }
    }

    @MainActor
    func testColdAppRestartSessionAndPreferencesRestoration() async {
        let authVM = AuthViewModel()
        await authVM.login(email: "quentin@algourmand.ch", password: "password123")
        XCTAssertTrue(authVM.isAuthenticated)
        guard let user = authVM.currentUser else {
            XCTFail("Missing authenticated user")
            return
        }

        let profile = UserProfile(
            id: user.id,
            age: 29,
            weight: 71.0,
            height: 177.0,
            activityLevel: .moderate,
            goal: .maintenance,
            allergies: ["lactose"],
            dietaryPreferences: ["vegetarian"],
            dislikedIngredients: ["Coriandre"]
        )
        authVM.saveCompletedProfile(profile)

        let weeklyVM = WeeklyPreferencesViewModel()
        weeklyVM.maxPreparationTime = 25
        weeklyVM.toggleCuisine("Italienne")
        XCTAssertTrue(weeklyVM.savePreferences(for: user.id))

        // Recreate AuthViewModel to simulate fresh application launch with persisted state
        let restartedAuthVM = AuthViewModel()

        XCTAssertTrue(restartedAuthVM.isAuthenticated)
        XCTAssertEqual(restartedAuthVM.currentUser?.id, user.id)
        XCTAssertEqual(restartedAuthVM.currentUser?.email, "quentin@algourmand.ch")
        XCTAssertTrue(restartedAuthVM.hasCompletedProfile)

        let reloadedProfile = LocalProfileStorage.shared.loadProfile(for: user.id)
        XCTAssertNotNil(reloadedProfile)
        XCTAssertEqual(reloadedProfile?.age, 29)
        XCTAssertEqual(reloadedProfile?.allergies, ["lactose"])

        let reloadedWeekly = LocalWeeklyPreferencesStorage.shared.loadPreferences(for: user.id)
        XCTAssertNotNil(reloadedWeekly)
        XCTAssertEqual(reloadedWeekly?.maxPreparationTime, 25)
        XCTAssertTrue(reloadedWeekly?.preferences.contains("Italienne") ?? false)

        await restartedAuthVM.logout()
        XCTAssertFalse(restartedAuthVM.isAuthenticated)
        XCTAssertNil(KeychainHelper.readToken())
    }
}
