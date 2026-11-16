import Foundation

public struct PlannedMeal: Identifiable, Codable, Hashable, Sendable {
    public enum MealType: String, Codable, CaseIterable, Sendable, Hashable {
        case breakfast
        case lunch
        case dinner
        case snack

        public var displayName: String {
            switch self {
            case .breakfast:
                return "Petit-déjeuner"
            case .lunch:
                return "Déjeuner"
            case .dinner:
                return "Dîner"
            case .snack:
                return "Collation"
            }
        }

        public var systemIcon: String {
            switch self {
            case .breakfast:
                return "sun.horizon.fill"
            case .lunch:
                return "sun.max.fill"
            case .dinner:
                return "moon.stars.fill"
            case .snack:
                return "apple.logo"
            }
        }
    }

    public let id: UUID
    public let date: Date
    public let mealType: MealType
    public let recipeId: UUID
    public let isLocked: Bool
    public let recipe: Recipe?

    public init(
        id: UUID = UUID(),
        date: Date,
        mealType: MealType,
        recipeId: UUID,
        isLocked: Bool = false,
        recipe: Recipe? = nil
    ) {
        self.id = id
        self.date = date
        self.mealType = mealType
        self.recipeId = recipeId
        self.isLocked = isLocked
        self.recipe = recipe
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case date
        case mealType = "meal_type"
        case recipeId = "recipe_id"
        case isLocked = "is_locked"
        case recipe
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.date = try container.decode(Date.self, forKey: .date)
        self.mealType = try container.decode(MealType.self, forKey: .mealType)
        self.recipeId = try container.decode(UUID.self, forKey: .recipeId)
        self.isLocked = try container.decodeIfPresent(Bool.self, forKey: .isLocked) ?? false
        self.recipe = try container.decodeIfPresent(Recipe.self, forKey: .recipe)
    }

    public func updatingLock(_ locked: Bool) -> PlannedMeal {
        PlannedMeal(
            id: id,
            date: date,
            mealType: mealType,
            recipeId: recipeId,
            isLocked: locked,
            recipe: recipe
        )
    }

    public func updatingRecipe(_ newRecipe: Recipe) -> PlannedMeal {
        PlannedMeal(
            id: id,
            date: date,
            mealType: mealType,
            recipeId: newRecipe.id,
            isLocked: isLocked,
            recipe: newRecipe
        )
    }
}
