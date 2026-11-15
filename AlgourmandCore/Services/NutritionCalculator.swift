import Foundation

public enum NutritionCalculator {

    // MARK: - Public Calculation API
    public static func calculateNeeds(for profile: UserProfile) -> NutritionNeeds {
        let effectiveWeight = profile.weight ?? defaultWeight(for: profile.gender)
        let effectiveHeight = profile.height ?? defaultHeight(for: profile.gender)
        let effectiveAge = max(profile.age, 10)
        let bmiMetrics = calculateBMI(weightKg: profile.weight, heightCm: profile.height)
        let bmr = calculateBMR(
            gender: profile.gender,
            weightKg: effectiveWeight,
            heightCm: effectiveHeight,
            ageYears: effectiveAge
        )

        let palMultiplier = activityMultiplier(for: profile.activityLevel)
        let tdee = round(bmr * palMultiplier)
        let (targetCalories, calorieAdjustment) = calculateTargetCalories(
            tdee: tdee,
            bmr: bmr,
            gender: profile.gender,
            goal: profile.goal,
            activity: profile.activityLevel
        )

        let proteins = calculateProteins(
            weightKg: effectiveWeight,
            targetCalories: targetCalories,
            goal: profile.goal,
            activity: profile.activityLevel
        )

        let fats = calculateFats(
            targetCalories: targetCalories
        )

        let carbs = calculateCarbohydrates(
            targetCalories: targetCalories,
            proteinsCalories: proteins.calories,
            fatsCalories: fats.calories
        )

        let waterLiters = calculateWaterNeeds(
            weightKg: effectiveWeight,
            activity: profile.activityLevel
        )
        let fiberGrams = calculateFiberNeeds(targetCalories: targetCalories)

        let summary = buildEducationalSummary(
            profile: profile,
            targetCalories: targetCalories,
            calorieAdjustment: calorieAdjustment,
            proteinsGrams: proteins.grams
        )

        return NutritionNeeds(
            bmi: bmiMetrics?.bmi,
            bmiCategory: bmiMetrics?.category,
            healthyWeightMin: bmiMetrics?.minWeight,
            healthyWeightMax: bmiMetrics?.maxWeight,
            bmr: round(bmr),
            tdee: tdee,
            targetCalories: round(targetCalories),
            calorieAdjustment: round(calorieAdjustment),
            proteinsGrams: proteins.grams,
            proteinsCalories: proteins.calories,
            proteinsPercentage: proteins.percentage,
            carbohydratesGrams: carbs.grams,
            carbohydratesCalories: carbs.calories,
            carbohydratesPercentage: carbs.percentage,
            fatsGrams: fats.grams,
            fatsCalories: fats.calories,
            fatsPercentage: fats.percentage,
            waterLiters: waterLiters,
            fiberGrams: fiberGrams,
            goalTitle: profile.goal.displayName,
            activityTitle: profile.activityLevel.displayName,
            educationalSummary: summary
        )
    }

    // MARK: - BMI Calculation
    public struct BMIMetrics: Equatable {
        public let bmi: Double
        public let category: BMICategory
        public let minWeight: Double
        public let maxWeight: Double
    }

    public static func calculateBMI(weightKg: Double?, heightCm: Double?) -> BMIMetrics? {
        guard let weight = weightKg, let height = heightCm, height > 0, weight > 0 else {
            return nil
        }
        let heightMeters = height / 100.0
        let bmiRaw = weight / (heightMeters * heightMeters)
        let bmi = (bmiRaw * 10).rounded() / 10

        let category: BMICategory
        switch bmi {
        case ..<18.5:
            category = .underweight
        case 18.5..<25.0:
            category = .normal
        case 25.0..<30.0:
            category = .overweight
        case 30.0..<35.0:
            category = .obeseClass1
        default:
            category = .obeseClass2
        }

        let minHealthyWeight = ((18.5 * heightMeters * heightMeters) * 10).rounded() / 10
        let maxHealthyWeight = ((24.9 * heightMeters * heightMeters) * 10).rounded() / 10

        return BMIMetrics(
            bmi: bmi,
            category: category,
            minWeight: minHealthyWeight,
            maxWeight: maxHealthyWeight
        )
    }

    // MARK: - BMR (Mifflin-St Jeor)
    private static func calculateBMR(
        gender: UserProfile.Gender?,
        weightKg: Double,
        heightCm: Double,
        ageYears: Int
    ) -> Double {
        let base = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * Double(ageYears))

        switch gender {
        case .male:
            return base + 5.0
        case .female:
            return base - 161.0
        case .other, .none:
            return base - 78.0
        }
    }

    // MARK: - Activity Multiplier (PAL)
    private static func activityMultiplier(for activity: UserProfile.ActivityLevel) -> Double {
        switch activity {
        case .sedentary:
            return 1.20
        case .moderate:
            return 1.375
        case .active:
            return 1.55
        case .veryActive:
            return 1.725
        }
    }

    // MARK: - Goal Calorie Adjustments
    private static func calculateTargetCalories(
        tdee: Double,
        bmr: Double,
        gender: UserProfile.Gender?,
        goal: UserProfile.NutritionGoal,
        activity: UserProfile.ActivityLevel
    ) -> (targetCalories: Double, adjustment: Double) {
        let minSafeCalories: Double = (gender == .female) ? 1250.0 : 1500.0

        switch goal {
        case .weightLoss:
            let deficit = max(350.0, min(tdee * 0.18, 600.0))
            let calculated = tdee - deficit
            let safeTarget = max(calculated, max(bmr, minSafeCalories))
            return (safeTarget, safeTarget - tdee)

        case .maintenance:
            return (tdee, 0.0)

        case .muscleGain:
            let surplusPct = (activity == .veryActive || activity == .active) ? 0.15 : 0.12
            let surplus = max(250.0, min(tdee * surplusPct, 450.0))
            let target = tdee + surplus
            return (target, surplus)
        }
    }

    // MARK: - Macronutrients Split
    private struct MacroBreakdown {
        let grams: Double
        let calories: Double
        let percentage: Double
    }

    private static func calculateProteins(
        weightKg: Double,
        targetCalories: Double,
        goal: UserProfile.NutritionGoal,
        activity: UserProfile.ActivityLevel
    ) -> MacroBreakdown {
        let proteinPerKg: Double
        switch goal {
        case .muscleGain:
            proteinPerKg = (activity == .veryActive) ? 2.2 : 2.0
        case .weightLoss:
            proteinPerKg = 1.9
        case .maintenance:
            proteinPerKg = (activity == .active || activity == .veryActive) ? 1.8 : 1.6
        }

        let rawGrams = weightKg * proteinPerKg
        let grams = round(rawGrams)
        let calories = grams * 4.0
        let percentage = ((calories / targetCalories) * 1000).rounded() / 10

        return MacroBreakdown(grams: grams, calories: calories, percentage: percentage)
    }

    private static func calculateFats(
        targetCalories: Double
    ) -> MacroBreakdown {
        let targetFatRatio = 0.28
        let calories = targetCalories * targetFatRatio
        let grams = round(calories / 9.0)
        let finalCalories = grams * 9.0
        let percentage = ((finalCalories / targetCalories) * 1000).rounded() / 10

        return MacroBreakdown(grams: grams, calories: finalCalories, percentage: percentage)
    }

    private static func calculateCarbohydrates(
        targetCalories: Double,
        proteinsCalories: Double,
        fatsCalories: Double
    ) -> MacroBreakdown {
        let remainingCalories = max(targetCalories - proteinsCalories - fatsCalories, 200.0)
        let grams = round(remainingCalories / 4.0)
        let calories = grams * 4.0
        let percentage = ((calories / targetCalories) * 1000).rounded() / 10

        return MacroBreakdown(grams: grams, calories: calories, percentage: percentage)
    }

    // MARK: - Water & Fiber Needs
    private static func calculateWaterNeeds(
        weightKg: Double,
        activity: UserProfile.ActivityLevel
    ) -> Double {
        let baseMl = weightKg * 35.0
        let activityBonusMl: Double
        switch activity {
        case .sedentary: activityBonusMl = 0.0
        case .moderate: activityBonusMl = 300.0
        case .active: activityBonusMl = 600.0
        case .veryActive: activityBonusMl = 1000.0
        }

        let totalLiters = (baseMl + activityBonusMl) / 1000.0
        return ((totalLiters * 10).rounded()) / 10
    }

    private static func calculateFiberNeeds(targetCalories: Double) -> Double {
        let fiber = (targetCalories / 1000.0) * 14.0
        return round(min(max(fiber, 25.0), 45.0))
    }

    // MARK: - Educational Summary
    private static func buildEducationalSummary(
        profile: UserProfile,
        targetCalories: Double,
        calorieAdjustment: Double,
        proteinsGrams: Double
    ) -> String {
        var parts: [String] = []

        let calInt = Int(targetCalories)
        let adjInt = Int(abs(calorieAdjustment))

        switch profile.goal {
        case .weightLoss:
            parts.append("Pour votre objectif de perte de poids, un déficit modéré de \(adjInt) kcal est appliqué (cible : \(calInt) kcal/j).")
            parts.append("L'apport en protéines est maintenu à \(Int(proteinsGrams))g pour protéger votre masse musculaire et favoriser la satiété.")
        case .maintenance:
            parts.append("Votre métabolisme est parfaitement équilibré à \(calInt) kcal/j pour stabiliser votre énergie au quotidien.")
            parts.append("La répartition des macronutriments soutient votre niveau d'activité \(profile.activityLevel.displayName.lowercased()).")
        case .muscleGain:
            parts.append("Pour stimuler la synthèse musculaire, un surplus anabolique de +\(adjInt) kcal est ciblé (\(calInt) kcal/j).")
            parts.append("Avec \(Int(proteinsGrams))g de protéines journalières, votre corps dispose des acides aminés essentiels à la récupération.")
        }

        return parts.joined(separator: " ")
    }

    // MARK: - Defaults
    private static func defaultWeight(for gender: UserProfile.Gender?) -> Double {
        switch gender {
        case .male: return 75.0
        case .female: return 62.0
        case .other, .none: return 68.0
        }
    }

    private static func defaultHeight(for gender: UserProfile.Gender?) -> Double {
        switch gender {
        case .male: return 178.0
        case .female: return 165.0
        case .other, .none: return 170.0
        }
    }
}
