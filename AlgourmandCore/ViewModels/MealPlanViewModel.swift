import Combine
import Foundation

@MainActor
public final class MealPlanViewModel: ObservableObject {
    // MARK: - Published State
    @Published public var currentPlan: WeeklyPlan?
    @Published public var selectedDate = Date()
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var feedbackMessage: String?

    // MARK: - Dependencies
    private let storage: LocalWeeklyPlanStorage
    private let engine: MealPlanningEngineProtocol
    private let recipeService: RecipeServiceProtocol

    public init(
        storage: LocalWeeklyPlanStorage = .shared,
        engine: MealPlanningEngineProtocol = MealPlanningEngine.shared,
        recipeService: RecipeServiceProtocol = TheMealDBService()
    ) {
        self.storage = storage
        self.engine = engine
        self.recipeService = recipeService
    }

    // MARK: - Plan Lifecycle
    public func loadPlan(for userId: UUID) {
        currentPlan = storage.loadPlan(for: userId)
    }

    public func generatePlan(
        for userId: UUID,
        profile: UserProfile,
        preferences: WeeklyPreferences?,
        startDate: Date = Date()
    ) async {
        isLoading = true
        errorMessage = nil

        var candidatePool = SampleRecipes.all

        // Fetch network recipes if available, fallback silently to local sample recipes
        if let networkRecipes = try? await recipeService.searchRecipes(query: ""), !networkRecipes.isEmpty {
            let existingIds = Set(candidatePool.map { $0.id })
            let uniqueNetwork = networkRecipes.filter { !existingIds.contains($0.id) }
            candidatePool.append(contentsOf: uniqueNetwork)
        }

        let existing = currentPlan ?? storage.loadPlan(for: userId)
        let generatedMeals = engine.selectMealsForWeek(
            startDate: startDate,
            recipes: candidatePool,
            profile: profile,
            preferences: preferences,
            existingPlan: existing
        )

        let newPlan = WeeklyPlan(
            weekStartDate: startDate,
            meals: generatedMeals,
            totalBudget: preferences?.budget ?? 0.0
        )

        storage.savePlan(newPlan, for: userId)
        currentPlan = newPlan
        selectedDate = startDate
        feedbackMessage = "Nouveau planning hebdomadaire généré avec succès !"
        isLoading = false
    }

    public func toggleMealLock(mealId: UUID, for userId: UUID) {
        guard let plan = currentPlan,
              let index = plan.meals.firstIndex(where: { $0.id == mealId }) else {
            return
        }

        var updatedMeals = plan.meals
        let currentLock = updatedMeals[index].isLocked
        updatedMeals[index] = updatedMeals[index].updatingLock(!currentLock)

        let updatedPlan = WeeklyPlan(
            id: plan.id,
            weekStartDate: plan.weekStartDate,
            meals: updatedMeals,
            totalBudget: plan.totalBudget
        )

        storage.savePlan(updatedPlan, for: userId)
        currentPlan = updatedPlan
    }

    public func regenerateMeal(
        mealId: UUID,
        for userId: UUID,
        profile: UserProfile,
        preferences: WeeklyPreferences?
    ) {
        guard let plan = currentPlan else { return }

        let candidates = SampleRecipes.all
        if let updatedPlan = engine.regenerateSingleMeal(
            mealId: mealId,
            in: plan,
            availableRecipes: candidates,
            profile: profile,
            preferences: preferences
        ) {
            storage.savePlan(updatedPlan, for: userId)
            currentPlan = updatedPlan
        }
    }

    // MARK: - Computed Properties for UI
    public var daysOfWeek: [Date] {
        guard let plan = currentPlan else { return [] }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: plan.weekStartDate)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    public var mealsForSelectedDate: [PlannedMeal] {
        guard let plan = currentPlan else { return [] }
        let calendar = Calendar.current
        return plan.meals
            .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { lhs, rhs -> Bool in
                (lhs.mealType == .lunch ? 0 : 1) < (rhs.mealType == .lunch ? 0 : 1)
            }
    }

    public var caloriesForSelectedDate: Double {
        mealsForSelectedDate.compactMap { $0.recipe?.calories }.reduce(0, +)
    }

    public var proteinsForSelectedDate: Double {
        mealsForSelectedDate.compactMap { $0.recipe?.proteins }.reduce(0, +)
    }

    public var carbsForSelectedDate: Double {
        mealsForSelectedDate.compactMap { $0.recipe?.carbohydrates }.reduce(0, +)
    }

    public var fatsForSelectedDate: Double {
        mealsForSelectedDate.compactMap { $0.recipe?.fats }.reduce(0, +)
    }

    // Next upcoming meal based on current hour
    public var nextUpcomingMeal: PlannedMeal? {
        guard let plan = currentPlan, !plan.meals.isEmpty else { return nil }

        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)

        if hour < 14 {
            // Priority: today's lunch, then dinner
            let todayMeals = plan.meals.filter { calendar.isDate($0.date, inSameDayAs: now) }
            return todayMeals.first { $0.mealType == .lunch } ?? todayMeals.first { $0.mealType == .dinner }
        } else if hour < 21 {
            // Priority: today's dinner
            let todayMeals = plan.meals.filter { calendar.isDate($0.date, inSameDayAs: now) }
            return todayMeals.first { $0.mealType == .dinner } ?? plan.meals.first
        } else {
            // After 21h: tomorrow's lunch
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) {
                let tomorrowMeals = plan.meals.filter { calendar.isDate($0.date, inSameDayAs: tomorrow) }
                return tomorrowMeals.first { $0.mealType == .lunch } ?? plan.meals.first
            }
            return plan.meals.first
        }
    }
}
