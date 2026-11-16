import Foundation

public protocol MealPlanningEngineProtocol: Sendable {
    func selectMealsForWeek(
        startDate: Date,
        recipes: [Recipe],
        profile: UserProfile,
        preferences: WeeklyPreferences?,
        existingPlan: WeeklyPlan?
    ) -> [PlannedMeal]

    func regenerateSingleMeal(
        mealId: UUID,
        in plan: WeeklyPlan,
        availableRecipes: [Recipe],
        profile: UserProfile,
        preferences: WeeklyPreferences?
    ) -> WeeklyPlan?
}

public struct MealPlanningEngine: MealPlanningEngineProtocol {
    public static let shared = MealPlanningEngine()

    private let filterService: RecipeFilterServiceProtocol

    public init(filterService: RecipeFilterServiceProtocol = RecipeFilterService.shared) {
        self.filterService = filterService
    }

    public func selectMealsForWeek(
        startDate: Date,
        recipes: [Recipe],
        profile: UserProfile,
        preferences: WeeklyPreferences?,
        existingPlan: WeeklyPlan? = nil
    ) -> [PlannedMeal] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startDate)

        // Filter candidate recipes according to allergies, diets, dislikes, and max prep time
        var candidates = filterService.filterRecipes(recipes, profile: profile, preferences: preferences)
        if candidates.isEmpty {
            candidates = recipes.isEmpty ? SampleRecipes.all : recipes
        }

        // Index existing locked meals by day index (0...6) and meal type
        var lockedSlots: [String: PlannedMeal] = [:]
        var usedRecipeIds = Set<UUID>()

        if let existing = existingPlan {
            for meal in existing.meals where meal.isLocked {
                let dayOffset = calendar.dateComponents([.day], from: startOfDay, to: calendar.startOfDay(for: meal.date)).day ?? 0
                if dayOffset >= 0 && dayOffset < 7 {
                    let key = "\(dayOffset)_\(meal.mealType.rawValue)"
                    lockedSlots[key] = meal
                    usedRecipeIds.insert(meal.recipeId)
                }
            }
        }

        // Prepare candidate queue excluding already locked recipes to maximize diversity
        var availableCandidates = candidates.filter { !usedRecipeIds.contains($0.id) }
        if availableCandidates.isEmpty {
            availableCandidates = candidates
        }

        var plannedMeals: [PlannedMeal] = []
        var candidateIndex = 0

        // Build 14 meals: 7 days * 2 meals (Lunch + Dinner)
        for dayIndex in 0..<7 {
            guard let dayDate = calendar.date(byAdding: .day, value: dayIndex, to: startOfDay) else {
                continue
            }

            let lunchSlotKey = "\(dayIndex)_\(PlannedMeal.MealType.lunch.rawValue)"
            let dinnerSlotKey = "\(dayIndex)_\(PlannedMeal.MealType.dinner.rawValue)"

            var previousDayCategory: String?

            // Lunch Slot
            if let lockedLunch = lockedSlots[lunchSlotKey] {
                plannedMeals.append(lockedLunch)
                previousDayCategory = lockedLunch.recipe?.category
            } else {
                let chosenRecipe = pickDiversifiedRecipe(
                    from: availableCandidates,
                    excludingCategory: nil,
                    fallbackIndex: &candidateIndex
                )
                usedRecipeIds.insert(chosenRecipe.id)
                previousDayCategory = chosenRecipe.category

                let lunchTime = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: dayDate) ?? dayDate
                let planned = PlannedMeal(
                    date: lunchTime,
                    mealType: .lunch,
                    recipeId: chosenRecipe.id,
                    isLocked: false,
                    recipe: chosenRecipe
                )
                plannedMeals.append(planned)
            }

            // Dinner Slot (avoid repeating same category as lunch on the same day)
            if let lockedDinner = lockedSlots[dinnerSlotKey] {
                plannedMeals.append(lockedDinner)
            } else {
                let chosenRecipe = pickDiversifiedRecipe(
                    from: availableCandidates,
                    excludingCategory: previousDayCategory,
                    fallbackIndex: &candidateIndex
                )
                usedRecipeIds.insert(chosenRecipe.id)

                let dinnerTime = calendar.date(bySettingHour: 19, minute: 30, second: 0, of: dayDate) ?? dayDate
                let planned = PlannedMeal(
                    date: dinnerTime,
                    mealType: .dinner,
                    recipeId: chosenRecipe.id,
                    isLocked: false,
                    recipe: chosenRecipe
                )
                plannedMeals.append(planned)
            }
        }

        return plannedMeals
    }

    public func regenerateSingleMeal(
        mealId: UUID,
        in plan: WeeklyPlan,
        availableRecipes: [Recipe],
        profile: UserProfile,
        preferences: WeeklyPreferences?
    ) -> WeeklyPlan? {
        guard let mealIndex = plan.meals.firstIndex(where: { $0.id == mealId }) else {
            return nil
        }

        let targetMeal = plan.meals[mealIndex]
        let currentRecipeIds = Set(plan.meals.map { $0.recipeId })

        var candidates = filterService.filterRecipes(availableRecipes, profile: profile, preferences: preferences)
        if candidates.isEmpty {
            candidates = availableRecipes.isEmpty ? SampleRecipes.all : availableRecipes
        }

        // Prefer candidates not yet in the weekly plan
        let unusedCandidates = candidates.filter { !currentRecipeIds.contains($0.id) }
        let chosenRecipe: Recipe
        if let firstUnused = unusedCandidates.first {
            chosenRecipe = firstUnused
        } else if let differentRecipe = candidates.first(where: { $0.id != targetMeal.recipeId }) {
            chosenRecipe = differentRecipe
        } else {
            chosenRecipe = candidates.first ?? targetMeal.recipe!
        }

        var updatedMeals = plan.meals
        updatedMeals[mealIndex] = targetMeal.updatingRecipe(chosenRecipe)

        return WeeklyPlan(
            id: plan.id,
            weekStartDate: plan.weekStartDate,
            meals: updatedMeals,
            totalBudget: plan.totalBudget
        )
    }

    // MARK: - Private Diversification Helper
    private func pickDiversifiedRecipe(
        from candidates: [Recipe],
        excludingCategory: String?,
        fallbackIndex: inout Int
    ) -> Recipe {
        guard !candidates.isEmpty else {
            return SampleRecipes.all[0]
        }

        if let excluded = excludingCategory {
            // Find next recipe that belongs to a different category
            for offset in 0..<candidates.count {
                let idx = (fallbackIndex + offset) % candidates.count
                let candidate = candidates[idx]
                if candidate.category.lowercased() != excluded.lowercased() {
                    fallbackIndex = (idx + 1) % candidates.count
                    return candidate
                }
            }
        }

        let chosen = candidates[fallbackIndex % candidates.count]
        fallbackIndex = (fallbackIndex + 1) % candidates.count
        return chosen
    }
}
