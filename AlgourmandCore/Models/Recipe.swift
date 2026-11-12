import Foundation

public struct Recipe: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let externalId: String?
    public let name: String
    public let image: String?
    public let category: String
    public let area: String?
    public let ingredients: [Ingredient]
    public let instructions: [String]
    public let preparationTime: Int
    public let calories: Double
    public let proteins: Double
    public let carbohydrates: Double
    public let fats: Double
    public let tags: [String]
    public let youtubeURL: String?

    public init(
        id: UUID = UUID(),
        externalId: String? = nil,
        name: String,
        image: String? = nil,
        category: String = "Plat",
        area: String? = nil,
        ingredients: [Ingredient] = [],
        instructions: [String] = [],
        preparationTime: Int = 0,
        calories: Double = 0.0,
        proteins: Double = 0.0,
        carbohydrates: Double = 0.0,
        fats: Double = 0.0,
        tags: [String] = [],
        youtubeURL: String? = nil
    ) {
        self.id = id
        self.externalId = externalId
        self.name = name
        self.image = image
        self.category = category
        self.area = area
        self.ingredients = ingredients
        self.instructions = instructions
        self.preparationTime = preparationTime
        self.calories = calories
        self.proteins = proteins
        self.carbohydrates = carbohydrates
        self.fats = fats
        self.tags = tags
        self.youtubeURL = youtubeURL
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case externalId = "external_id"
        case name
        case image
        case category
        case area
        case ingredients
        case instructions
        case preparationTime = "preparation_time"
        case calories
        case proteins
        case carbohydrates
        case fats
        case tags
        case youtubeURL = "youtube_url"
    }
}
