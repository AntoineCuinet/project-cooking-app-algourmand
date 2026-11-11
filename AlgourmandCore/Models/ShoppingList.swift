import Foundation

public struct ShoppingList: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let weekPlanId: UUID
    public let ingredients: [Ingredient]

    public init(
        id: UUID = UUID(),
        weekPlanId: UUID,
        ingredients: [Ingredient] = []
    ) {
        self.id = id
        self.weekPlanId = weekPlanId
        self.ingredients = ingredients
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case weekPlanId = "week_plan_id"
        case ingredients
    }
}
