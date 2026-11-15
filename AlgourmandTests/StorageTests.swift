@testable import AlgourmandCore
import XCTest

final class StorageTests: XCTestCase {
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

    func testModelsCreationAndEncoding() throws {
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

        let recipeId = UUID()
        let meal = PlannedMeal(
            date: Date(),
            mealType: .dinner,
            recipeId: recipeId,
            isLocked: true
        )
        XCTAssertEqual(meal.mealType, .dinner)
        XCTAssertTrue(meal.isLocked)

        let plan = WeeklyPlan(
            weekStartDate: Date(),
            meals: [meal],
            totalBudget: 85.50
        )
        XCTAssertEqual(plan.meals.count, 1)
        XCTAssertEqual(plan.totalBudget, 85.50)

        let prefs = WeeklyPreferences(
            budget: 90.0,
            dailyCalories: 2200,
            preferences: ["Bio"],
            availableIngredients: ["Riz", "Huile d'olive"],
            numberOfPeople: 2
        )
        XCTAssertEqual(prefs.numberOfPeople, 2)
        XCTAssertEqual(prefs.dailyCalories, 2200)

        let shoppingList = ShoppingList(
            weekPlanId: plan.id,
            ingredients: [
                Ingredient(name: "Lait", quantity: 1, unit: "L")
            ]
        )
        XCTAssertEqual(shoppingList.weekPlanId, plan.id)
        XCTAssertEqual(shoppingList.ingredients.count, 1)

        let encoder = JSONEncoder()
        let profileData = try encoder.encode(profile)
        let decoder = JSONDecoder()
        let decodedProfile = try decoder.decode(UserProfile.self, from: profileData)
        XCTAssertEqual(profile.id, decodedProfile.id)
        XCTAssertEqual(profile.age, decodedProfile.age)
    }
}
