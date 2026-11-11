@testable import AlgourmandCore
import XCTest

final class AlgourmandTests: XCTestCase {
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

    func testRecipeInitialization() {
        let recipeId = UUID()
        let ingredientId = UUID()
        let ingredient = Ingredient(
            id: ingredientId,
            name: "Pommes de terre",
            quantity: 1000,
            unit: "g"
        )

        let recipe = Recipe(
            id: recipeId,
            name: "Gratin Dauphinois",
            image: "https://example.com/gratin.jpg",
            category: "Plat",
            ingredients: [ingredient],
            instructions: ["Éplucher les pommes de terre", "Cuire au four"],
            preparationTime: 60,
            calories: 520,
            proteins: 12,
            carbohydrates: 45,
            fats: 28
        )

        XCTAssertEqual(recipe.id, recipeId)
        XCTAssertEqual(recipe.name, "Gratin Dauphinois")
        XCTAssertEqual(recipe.category, "Plat")
        XCTAssertEqual(recipe.preparationTime, 60)
        XCTAssertEqual(recipe.calories, 520)
        XCTAssertEqual(recipe.ingredients.count, 1)
        XCTAssertEqual(recipe.ingredients.first?.name, "Pommes de terre")
    }

    func testModelsCreationAndEncoding() throws {
        // UserProfile
        let profile = UserProfile(
            age: 28,
            weight: 72.5,
            height: 178,
            activityLevel: .active,
            goal: .muscleGain,
            allergies: ["Arachides"],
            dietaryPreferences: ["Sans gluten"],
            dislikedIngredients: ["Céleri"]
        )
        XCTAssertEqual(profile.activityLevel, .active)
        XCTAssertEqual(profile.goal, .muscleGain)

        // PlannedMeal
        let recipeId = UUID()
        let meal = PlannedMeal(
            date: Date(),
            mealType: .dinner,
            recipeId: recipeId,
            isLocked: true
        )
        XCTAssertEqual(meal.mealType, .dinner)
        XCTAssertTrue(meal.isLocked)

        // WeeklyPlan
        let plan = WeeklyPlan(
            weekStartDate: Date(),
            meals: [meal],
            totalBudget: 85.50
        )
        XCTAssertEqual(plan.meals.count, 1)
        XCTAssertEqual(plan.totalBudget, 85.50)

        // WeeklyPreferences
        let prefs = WeeklyPreferences(
            budget: 90.0,
            dailyCalories: 2200,
            preferences: ["Bio"],
            availableIngredients: ["Riz", "Huile d'olive"],
            numberOfPeople: 2
        )
        XCTAssertEqual(prefs.numberOfPeople, 2)
        XCTAssertEqual(prefs.dailyCalories, 2200)

        // ShoppingList
        let shoppingList = ShoppingList(
            weekPlanId: plan.id,
            ingredients: [
                Ingredient(name: "Lait", quantity: 1, unit: "L")
            ]
        )
        XCTAssertEqual(shoppingList.weekPlanId, plan.id)
        XCTAssertEqual(shoppingList.ingredients.count, 1)

        // Codable check
        let encoder = JSONEncoder()
        let profileData = try encoder.encode(profile)
        let decoder = JSONDecoder()
        let decodedProfile = try decoder.decode(UserProfile.self, from: profileData)
        XCTAssertEqual(profile.id, decodedProfile.id)
        XCTAssertEqual(profile.age, decodedProfile.age)
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
            XCTFail("Le login aurait dû échouer avec de mauvais identifiants")
        } catch let error as APIErrorResponse {
            XCTAssertEqual(error.message, "Invalid credentials.")
        } catch {
            XCTFail("Type d'erreur inattendu: \(error)")
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
            XCTFail("L'inscription aurait dû échouer pour email déjà pris")
        } catch let error as APIErrorResponse {
            XCTAssertEqual(error.message, "The email has already been taken.")
            XCTAssertNotNil(error.errors?["email"])
        } catch {
            XCTFail("Type d'erreur inattendu: \(error)")
        }
    }

    func testMockFetchUserAndLogout() async throws {
        // Connexion
        _ = try await mockService.login(request: LoginRequest(email: "quentin@algourmand.ch", password: "password123"))

        // Fetch User
        let user = try await mockService.fetchCurrentUser()
        XCTAssertEqual(user.username, "chef_quentin")

        // Déconnexion
        try await mockService.logout()
        XCTAssertNil(mockService.currentToken)

        // Récupérer l'utilisateur après déconnexion doit renvoyer 401 Unauthenticated
        do {
            _ = try await mockService.fetchCurrentUser()
            XCTFail("fetchCurrentUser aurait dû échouer après déconnexion")
        } catch let error as APIErrorResponse {
            XCTAssertEqual(error.message, "Unauthenticated.")
        }
    }
}
