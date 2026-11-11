import Foundation

public struct PlannedMeal: Identifiable, Codable, Hashable, Sendable {
    public enum MealType: String, Codable, CaseIterable, Sendable, Hashable {
        case breakfast
        case lunch
        case dinner
        case snack
    }

    public let id: UUID
    public let date: Date
    public let mealType: MealType
    public let recipeId: UUID
    public let isLocked: Bool

    public init(
        id: UUID = UUID(),
        date: Date,
        mealType: MealType,
        recipeId: UUID,
        isLocked: Bool = false
    ) {
        self.id = id
        self.date = date
        self.mealType = mealType
        self.recipeId = recipeId
        self.isLocked = isLocked
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case date
        case mealType = "meal_type"
        case recipeId = "recipe_id"
        case isLocked = "is_locked"
    }
}
