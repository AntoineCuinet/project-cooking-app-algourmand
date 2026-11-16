@testable import AlgourmandCore
import XCTest

final class MealPlanningTests: XCTestCase {
    private let engine = MealPlanningEngine.shared
    private let storage = LocalWeeklyPlanStorage.shared

    func testMealPlanningSelects14DiversifiedMeals() {
        let samplePool = SampleRecipes.all
        let profile = UserProfile(
            age: 28,
            activityLevel: .active,
            goal: .maintenance,
            allergies: [],
            dietaryPreferences: ["omnivore"],
            dislikedIngredients: []
        )
        let preferences = WeeklyPreferences(
            budget: 80,
            dailyCalories: 2200,
            maxPreparationTime: 45,
            preferences: ["Italienne"],
            availableIngredients: ["Courgettes"],
            numberOfPeople: 2
        )

        let startDate = Date()
        let meals = engine.selectMealsForWeek(
            startDate: startDate,
            recipes: samplePool,
            profile: profile,
            preferences: preferences,
            existingPlan: nil
        )

        // 7 days * 2 meals (lunch & dinner)
        XCTAssertEqual(meals.count, 14)

        let lunches = meals.filter { $0.mealType == .lunch }
        let dinners = meals.filter { $0.mealType == .dinner }
        XCTAssertEqual(lunches.count, 7)
        XCTAssertEqual(dinners.count, 7)

        // With 16 sample recipes, all 14 slots must receive distinct recipes
        let uniqueRecipeIds = Set(meals.map { $0.recipeId })
        XCTAssertEqual(uniqueRecipeIds.count, 14)
    }

    func testMealPlanningPreservesLockedMeals() {
        let samplePool = SampleRecipes.all
        let profile = UserProfile(
            age: 28,
            activityLevel: .active,
            goal: .maintenance
        )

        let startDate = Calendar.current.startOfDay(for: Date())
        let initialMeals = engine.selectMealsForWeek(
            startDate: startDate,
            recipes: samplePool,
            profile: profile,
            preferences: nil,
            existingPlan: nil
        )

        // Lock first lunch meal
        var modifiedMeals = initialMeals
        let lockedMeal = modifiedMeals[0].updatingLock(true)
        modifiedMeals[0] = lockedMeal
        let initialPlan = WeeklyPlan(weekStartDate: startDate, meals: modifiedMeals)

        // Regenerate plan with existing plan provided
        let regeneratedMeals = engine.selectMealsForWeek(
            startDate: startDate,
            recipes: samplePool,
            profile: profile,
            preferences: nil,
            existingPlan: initialPlan
        )

        XCTAssertEqual(regeneratedMeals[0].recipeId, lockedMeal.recipeId)
        XCTAssertTrue(regeneratedMeals[0].isLocked)
    }

    func testRegenerateSingleMealReplacesTargetMeal() {
        let samplePool = SampleRecipes.all
        let profile = UserProfile(age: 25, activityLevel: .sedentary, goal: .maintenance)
        let startDate = Date()

        let meals = engine.selectMealsForWeek(
            startDate: startDate,
            recipes: samplePool,
            profile: profile,
            preferences: nil
        )
        let plan = WeeklyPlan(weekStartDate: startDate, meals: meals)

        let mealToReplace = meals[0]
        let updatedPlan = engine.regenerateSingleMeal(
            mealId: mealToReplace.id,
            in: plan,
            availableRecipes: samplePool,
            profile: profile,
            preferences: nil
        )

        XCTAssertNotNil(updatedPlan)
        let replacedMeal = updatedPlan?.meals.first { $0.id == mealToReplace.id }
        XCTAssertNotEqual(replacedMeal?.recipeId, mealToReplace.recipeId)
    }

    @MainActor
    func testMealPlanViewModelLifecycleAndLockToggle() async {
        let userId = UUID()
        let viewModel = MealPlanViewModel(storage: storage, engine: engine)

        let profile = UserProfile(age: 29, activityLevel: .moderate, goal: .maintenance)
        let preferences = WeeklyPreferences(
            budget: 90,
            dailyCalories: 2100,
            maxPreparationTime: 30,
            preferences: ["Française"]
        )

        await viewModel.generatePlan(for: userId, profile: profile, preferences: preferences)

        XCTAssertNotNil(viewModel.currentPlan)
        XCTAssertEqual(viewModel.currentPlan?.meals.count, 14)
        XCTAssertEqual(viewModel.daysOfWeek.count, 7)

        guard let firstMeal = viewModel.currentPlan?.meals.first else {
            XCTFail("Missing planned meal")
            return
        }

        XCTAssertFalse(firstMeal.isLocked)
        viewModel.toggleMealLock(mealId: firstMeal.id, for: userId)

        let reloadedPlan = storage.loadPlan(for: userId)
        let updatedMeal = reloadedPlan?.meals.first { $0.id == firstMeal.id }
        XCTAssertTrue(updatedMeal?.isLocked ?? false)

        XCTAssertNotNil(viewModel.nextUpcomingMeal)

        // Cleanup
        storage.deletePlan(for: userId)
        XCTAssertNil(storage.loadPlan(for: userId))
    }
}
