import Foundation

public struct UserProfile: Identifiable, Codable, Hashable, Sendable {
    public enum ActivityLevel: String, Codable, CaseIterable, Sendable {
        case sedentary = "sedentary"
        case moderate = "moderate"
        case active = "active"
        case veryActive = "very_active"
    }

    public enum NutritionGoal: String, Codable, CaseIterable, Sendable {
        case weightLoss = "weight_loss"
        case maintenance = "maintenance"
        case muscleGain = "muscle_gain"
    }

    public let id: UUID
    public let age: Int
    public let weight: Double?
    public let height: Double?
    public let activityLevel: ActivityLevel
    public let goal: NutritionGoal
    public let allergies: [String]
    public let dietaryPreferences: [String]
    public let dislikedIngredients: [String]

    public init(id: UUID = UUID(), age: Int, weight: Double? = nil, height: Double? = nil, activityLevel: ActivityLevel, goal: NutritionGoal, allergies: [String] = [], dietaryPreferences: [String] = [], dislikedIngredients: [String] = []) {
        self.id = id
        self.age = age
        self.weight = weight
        self.height = height
        self.activityLevel = activityLevel
        self.goal = goal
        self.allergies = allergies
        self.dietaryPreferences = dietaryPreferences
        self.dislikedIngredients = dislikedIngredients
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case age
        case weight
        case height
        case activityLevel = "activity_level"
        case goal
        case allergies
        case dietaryPreferences = "dietary_preferences"
        case dislikedIngredients = "disliked_ingredients"
    }
}
