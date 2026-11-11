import Foundation

public struct WeeklyPreferences: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let budget: Double
    public let dailyCalories: Int
    public let maxPreparationTime: Int?
    public let preferences: [String]
    public let availableIngredients: [String]
    public let numberOfPeople: Int

    public init(
        id: UUID = UUID(),
        budget: Double,
        dailyCalories: Int,
        maxPreparationTime: Int? = nil,
        preferences: [String] = [],
        availableIngredients: [String] = [],
        numberOfPeople: Int = 1
    ) {
        self.id = id
        self.budget = budget
        self.dailyCalories = dailyCalories
        self.maxPreparationTime = maxPreparationTime
        self.preferences = preferences
        self.availableIngredients = availableIngredients
        self.numberOfPeople = numberOfPeople
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case budget
        case dailyCalories = "daily_calories"
        case maxPreparationTime = "max_preparation_time"
        case preferences
        case availableIngredients = "available_ingredients"
        case numberOfPeople = "number_of_people"
    }
}
