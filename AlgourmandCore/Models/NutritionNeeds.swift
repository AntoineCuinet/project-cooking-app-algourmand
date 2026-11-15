import Foundation

/// Body Mass Index Categories (according to the WHO)
public enum BMICategory: String, Codable, CaseIterable, Sendable {
    case underweight = "underweight"
    case normal = "normal"
    case overweight = "overweight"
    case obeseClass1 = "obese_class_1"
    case obeseClass2 = "obese_class_2"

    public var title: String {
        switch self {
        case .underweight:
            return "Insuffisance pondérale"
        case .normal:
            return "Poids santé"
        case .overweight:
            return "Surpoids modéré"
        case .obeseClass1:
            return "Obésité modérée"
        case .obeseClass2:
            return "Obésité sévère"
        }
    }

    public var shortBadge: String {
        switch self {
        case .underweight:
            return "Insuffisance"
        case .normal:
            return "Normal"
        case .overweight:
            return "Surpoids"
        case .obeseClass1, .obeseClass2:
            return "Obésité"
        }
    }

    public var systemIcon: String {
        switch self {
        case .underweight:
            return "arrow.down.forward.circle.fill"
        case .normal:
            return "checkmark.circle.fill"
        case .overweight:
            return "exclamationmark.circle.fill"
        case .obeseClass1, .obeseClass2:
            return "exclamationmark.triangle.fill"
        }
    }
}

public struct NutritionNeeds: Equatable, Hashable, Codable, Sendable {
    // MARK: - BMI & Body Metrics
    public let bmi: Double?
    public let bmiCategory: BMICategory?
    public let healthyWeightMin: Double?
    public let healthyWeightMax: Double?

    // MARK: - Energy & Metabolism (kcal)
    public let bmr: Double
    public let tdee: Double
    public let targetCalories: Double
    public let calorieAdjustment: Double

    // MARK: - Macronutrients
    public let proteinsGrams: Double
    public let proteinsCalories: Double
    public let proteinsPercentage: Double

    public let carbohydratesGrams: Double
    public let carbohydratesCalories: Double
    public let carbohydratesPercentage: Double

    public let fatsGrams: Double
    public let fatsCalories: Double
    public let fatsPercentage: Double

    // MARK: - Micronutrients & Lifestyle
    public let waterLiters: Double
    public let fiberGrams: Double

    // MARK: - Explanations & Summary
    public let goalTitle: String
    public let activityTitle: String
    public let educationalSummary: String

    public init(
        bmi: Double?,
        bmiCategory: BMICategory?,
        healthyWeightMin: Double?,
        healthyWeightMax: Double?,
        bmr: Double,
        tdee: Double,
        targetCalories: Double,
        calorieAdjustment: Double,
        proteinsGrams: Double,
        proteinsCalories: Double,
        proteinsPercentage: Double,
        carbohydratesGrams: Double,
        carbohydratesCalories: Double,
        carbohydratesPercentage: Double,
        fatsGrams: Double,
        fatsCalories: Double,
        fatsPercentage: Double,
        waterLiters: Double,
        fiberGrams: Double,
        goalTitle: String,
        activityTitle: String,
        educationalSummary: String
    ) {
        self.bmi = bmi
        self.bmiCategory = bmiCategory
        self.healthyWeightMin = healthyWeightMin
        self.healthyWeightMax = healthyWeightMax
        self.bmr = bmr
        self.tdee = tdee
        self.targetCalories = targetCalories
        self.calorieAdjustment = calorieAdjustment
        self.proteinsGrams = proteinsGrams
        self.proteinsCalories = proteinsCalories
        self.proteinsPercentage = proteinsPercentage
        self.carbohydratesGrams = carbohydratesGrams
        self.carbohydratesCalories = carbohydratesCalories
        self.carbohydratesPercentage = carbohydratesPercentage
        self.fatsGrams = fatsGrams
        self.fatsCalories = fatsCalories
        self.fatsPercentage = fatsPercentage
        self.waterLiters = waterLiters
        self.fiberGrams = fiberGrams
        self.goalTitle = goalTitle
        self.activityTitle = activityTitle
        self.educationalSummary = educationalSummary
    }
}
