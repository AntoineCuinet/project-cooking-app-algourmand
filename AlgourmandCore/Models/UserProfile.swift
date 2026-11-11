import Foundation

public struct UserProfile: Identifiable, Codable, Hashable, Sendable {
    public enum ActivityLevel: String, Codable, CaseIterable, Sendable {
        case sedentary = "sedentary"
        case moderate = "moderate"
        case active = "active"
        case veryActive = "very_active"

        public var displayName: String {
            switch self {
            case .sedentary:
                return "Sédentaire"
            case .moderate:
                return "Modéré"
            case .active:
                return "Actif"
            case .veryActive:
                return "Très actif"
            }
        }

        public var subtitle: String {
            switch self {
            case .sedentary:
                return "Peu ou pas d'exercice régulier"
            case .moderate:
                return "Activité modérée (1 à 3 fois/semaine)"
            case .active:
                return "Sport régulier (4 à 5 fois/semaine)"
            case .veryActive:
                return "Activité intense quotidienne ou travail physique"
            }
        }

        public var systemIcon: String {
            switch self {
            case .sedentary:
                return "bed.double.fill"
            case .moderate:
                return "figure.walk"
            case .active:
                return "figure.run"
            case .veryActive:
                return "flame.fill"
            }
        }
    }

    public enum NutritionGoal: String, Codable, CaseIterable, Sendable {
        case weightLoss = "weight_loss"
        case maintenance = "maintenance"
        case muscleGain = "muscle_gain"

        public var displayName: String {
            switch self {
            case .weightLoss:
                return "Perte de poids"
            case .maintenance:
                return "Maintien & Équilibre"
            case .muscleGain:
                return "Prise de masse"
            }
        }

        public var subtitle: String {
            switch self {
            case .weightLoss:
                return "Recettes légères et rassasiantes pour un déficit modéré sans frustration"
            case .maintenance:
                return "Repas complets et équilibrés pour stabiliser votre énergie au quotidien"
            case .muscleGain:
                return "Apports protéiques renforcés et surplus sain pour le développement musculaire"
            }
        }

        public var systemIcon: String {
            switch self {
            case .weightLoss:
                return "flame.fill"
            case .maintenance:
                return "leaf.fill"
            case .muscleGain:
                return "dumbbell.fill"
            }
        }
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
