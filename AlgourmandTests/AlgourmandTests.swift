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

    @MainActor
    func testProfileSetupViewModelNavigation() {
        let viewModel = ProfileSetupViewModel()

        XCTAssertEqual(viewModel.currentStep, .physicalInfo)
        XCTAssertEqual(viewModel.currentStepIndex, 0)
        XCTAssertEqual(viewModel.totalSteps, 5)
        XCTAssertFalse(viewModel.canGoBack)
        XCTAssertFalse(viewModel.isLastStep)
        XCTAssertEqual(viewModel.progress, 0.2)

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .nutritionGoal)
        XCTAssertTrue(viewModel.canGoBack)
        XCTAssertEqual(viewModel.progress, 0.4)

        viewModel.previousStep()
        XCTAssertEqual(viewModel.currentStep, .physicalInfo)
        XCTAssertFalse(viewModel.canGoBack)

        viewModel.nextStep() // 1
        viewModel.nextStep() // 2
        viewModel.nextStep() // 3
        viewModel.nextStep() // 4
        XCTAssertEqual(viewModel.currentStep, .dislikedIngredients)
        XCTAssertTrue(viewModel.isLastStep)
        XCTAssertEqual(viewModel.progress, 1.0)

        viewModel.nextStep()
        XCTAssertTrue(viewModel.isCompleted)
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
        // login
        _ = try await mockService.login(request: LoginRequest(email: "quentin@algourmand.ch", password: "password123"))

        // Fetch User
        let user = try await mockService.fetchCurrentUser()
        XCTAssertEqual(user.username, "chef_quentin")

        // logout
        try await mockService.logout()
        XCTAssertNil(mockService.currentToken)

        // 401 Unauthenticated
        do {
            _ = try await mockService.fetchCurrentUser()
            XCTFail("fetchCurrentUser aurait dû échouer après déconnexion")
        } catch let error as APIErrorResponse {
            XCTAssertEqual(error.message, "Unauthenticated.")
        }
    }

    @MainActor
    func testProfileSetupPhysicalInfoValidation() {
        let viewModel = ProfileSetupViewModel()
        XCTAssertEqual(viewModel.currentStep, .physicalInfo)
        XCTAssertFalse(viewModel.isAgeValid)
        XCTAssertFalse(viewModel.isPhysicalInfoValid)
        XCTAssertFalse(viewModel.canProceedFromCurrentStep)
        XCTAssertNotNil(viewModel.physicalInfoValidationError)

        viewModel.ageText = "abc"
        XCTAssertNil(viewModel.ageValue)
        XCTAssertFalse(viewModel.isAgeValid)

        viewModel.ageText = "9"
        XCTAssertFalse(viewModel.isAgeValid)

        viewModel.ageText = "121"
        XCTAssertFalse(viewModel.isAgeValid)

        viewModel.ageText = "28"
        XCTAssertEqual(viewModel.ageValue, 28)
        XCTAssertTrue(viewModel.isAgeValid)
        XCTAssertTrue(viewModel.isWeightValid)
        XCTAssertTrue(viewModel.isHeightValid)
        XCTAssertTrue(viewModel.isPhysicalInfoValid)
        XCTAssertTrue(viewModel.canProceedFromCurrentStep)

        viewModel.heightText = "178,5"
        viewModel.weightText = "72,4"
        XCTAssertEqual(viewModel.heightValue, 178.5)
        XCTAssertEqual(viewModel.weightValue, 72.4)
        XCTAssertTrue(viewModel.isHeightValid)
        XCTAssertTrue(viewModel.isWeightValid)
        XCTAssertTrue(viewModel.isPhysicalInfoValid)

        viewModel.weightText = "10"
        XCTAssertFalse(viewModel.isWeightValid)
        XCTAssertFalse(viewModel.canProceedFromCurrentStep)

        viewModel.weightText = "72,4"
        XCTAssertTrue(viewModel.canProceedFromCurrentStep)

        viewModel.activityLevel = .veryActive
        XCTAssertEqual(viewModel.activityLevel, .veryActive)

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .nutritionGoal)

        XCTAssertEqual(viewModel.nutritionGoal, .maintenance)
        XCTAssertTrue(viewModel.canProceedFromCurrentStep)

        viewModel.nutritionGoal = .weightLoss
        XCTAssertEqual(viewModel.nutritionGoal, .weightLoss)

        for goal in UserProfile.NutritionGoal.allCases {
            XCTAssertFalse(goal.displayName.isEmpty)
            XCTAssertFalse(goal.subtitle.isEmpty)
            XCTAssertFalse(goal.systemIcon.isEmpty)
        }

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .dietaryPreferences)
        viewModel.toggleDietaryPreference("vegetarian")
        XCTAssertTrue(viewModel.isDietaryPreferenceSelected("vegetarian"))
        viewModel.toggleDietaryPreference("vegetarian")
        XCTAssertFalse(viewModel.isDietaryPreferenceSelected("vegetarian"))
        viewModel.toggleDietaryPreference("omnivore")

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .allergies)
        viewModel.toggleAllergy("gluten")
        viewModel.toggleAllergy("peanuts")
        XCTAssertTrue(viewModel.isAllergySelected("gluten"))
        XCTAssertTrue(viewModel.isAllergySelected("peanuts"))
        XCTAssertFalse(viewModel.isAllergySelected("lactose"))
        viewModel.clearAllergies()
        XCTAssertFalse(viewModel.isAllergySelected("gluten"))
        viewModel.toggleAllergy("peanuts")

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .dislikedIngredients)
        XCTAssertTrue(viewModel.isLastStep)
        viewModel.addDislikedIngredient("Coriandre")
        viewModel.addDislikedIngredient("Céleri")
        viewModel.addDislikedIngredient("coriandre")
        XCTAssertEqual(viewModel.dislikedIngredients.count, 2)
        viewModel.removeDislikedIngredient("Céleri")
        XCTAssertEqual(viewModel.dislikedIngredients, ["Coriandre"])

        viewModel.nextStep()
        XCTAssertTrue(viewModel.isCompleted)

        let profile = viewModel.buildUserProfile()
        XCTAssertEqual(profile.age, 28)
        XCTAssertEqual(profile.height, 178.5)
        XCTAssertEqual(profile.weight, 72.4)
        XCTAssertEqual(profile.activityLevel, .veryActive)
        XCTAssertEqual(profile.goal, .weightLoss)
        XCTAssertEqual(profile.dietaryPreferences, ["omnivore"])
        XCTAssertEqual(profile.allergies, ["peanuts"])
        XCTAssertEqual(profile.dislikedIngredients, ["Coriandre"])
    }

    func testLocalProfileAndUserStorage() {
        let userId = UUID()
        let profile = UserProfile(
            id: userId,
            age: 30,
            weight: 75.0,
            height: 180.0,
            activityLevel: .active,
            goal: .muscleGain,
            allergies: ["gluten"],
            dietaryPreferences: ["omnivore"],
            dislikedIngredients: ["Foie"]
        )

        let profileStorage = LocalProfileStorage.shared
        XCTAssertTrue(profileStorage.saveProfile(profile, for: userId))

        let loadedProfile = profileStorage.loadProfile(for: userId)
        XCTAssertNotNil(loadedProfile)
        XCTAssertEqual(loadedProfile?.age, 30)
        XCTAssertEqual(loadedProfile?.goal, .muscleGain)

        XCTAssertTrue(profileStorage.deleteProfile(for: userId))
        XCTAssertNil(profileStorage.loadProfile(for: userId))

        // User Storage
        let user = UserDTO(id: userId, username: "antoine", email: "antoine@example.com")
        let userStorage = LocalUserStorage.shared
        XCTAssertTrue(userStorage.saveCurrentUser(user))

        let loadedUser = userStorage.loadCurrentUser()
        XCTAssertEqual(loadedUser?.username, "antoine")
        XCTAssertEqual(loadedUser?.email, "antoine@example.com")

        XCTAssertTrue(userStorage.clearCurrentUser())
        XCTAssertNil(userStorage.loadCurrentUser())
    }

    func testKeychainHelperTokenStorage() {
        let token = "test_bearer_token_12345"
        XCTAssertTrue(KeychainHelper.saveToken(token))
        XCTAssertEqual(KeychainHelper.readToken(), token)

        XCTAssertTrue(KeychainHelper.deleteToken())
        XCTAssertNil(KeychainHelper.readToken())
    }
}
