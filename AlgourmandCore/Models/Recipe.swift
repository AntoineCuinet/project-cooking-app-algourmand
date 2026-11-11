import Foundation

public struct Recipe: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let image: String?
    public let category: String
    public let ingredients: [Ingredient]
    public let instructions: [String]
    public let preparationTime: Int
    public let calories: Double
    public let proteins: Double
    public let carbohydrates: Double
    public let fats: Double

    public init(
        id: UUID = UUID(),
        name: String,
        image: String? = nil,
        category: String = "Plat",
        ingredients: [Ingredient] = [],
        instructions: [String] = [],
        preparationTime: Int = 0,
        calories: Double = 0.0,
        proteins: Double = 0.0,
        carbohydrates: Double = 0.0,
        fats: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.category = category
        self.ingredients = ingredients
        self.instructions = instructions
        self.preparationTime = preparationTime
        self.calories = calories
        self.proteins = proteins
        self.carbohydrates = carbohydrates
        self.fats = fats
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case category
        case ingredients
        case instructions
        case preparationTime = "preparation_time"
        case calories
        case proteins
        case carbohydrates
        case fats
    }
}
