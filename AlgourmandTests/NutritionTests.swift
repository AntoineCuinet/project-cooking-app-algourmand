@testable import AlgourmandCore
import XCTest

final class NutritionTests: XCTestCase {
    func testBMICalculationAndCategories() {
        let normalMetrics = NutritionCalculator.calculateBMI(weightKg: 70.0, heightCm: 175.0)
        XCTAssertNotNil(normalMetrics)
        XCTAssertEqual(normalMetrics?.bmi, 22.9)
        XCTAssertEqual(normalMetrics?.category, .normal)
        XCTAssertEqual(normalMetrics?.minWeight, 56.7)
        XCTAssertEqual(normalMetrics?.maxWeight, 76.3)

        let underMetrics = NutritionCalculator.calculateBMI(weightKg: 48.0, heightCm: 170.0)
        XCTAssertEqual(underMetrics?.category, .underweight)

        let overMetrics = NutritionCalculator.calculateBMI(weightKg: 85.0, heightCm: 175.0)
        XCTAssertEqual(overMetrics?.category, .overweight)

        let obeseMetrics = NutritionCalculator.calculateBMI(weightKg: 100.0, heightCm: 175.0)
        XCTAssertEqual(obeseMetrics?.category, .obeseClass1)

        XCTAssertNil(NutritionCalculator.calculateBMI(weightKg: nil, heightCm: 180.0))
        XCTAssertNil(NutritionCalculator.calculateBMI(weightKg: 70.0, heightCm: nil))
    }

    func testMifflinStJeorBMRAndActivityCalculations() {
        let maleProfile = UserProfile(
            gender: .male,
            age: 28,
            weight: 74.0,
            height: 180.0,
            activityLevel: .active,
            goal: .maintenance
        )

        let needs = NutritionCalculator.calculateNeeds(for: maleProfile)
        XCTAssertEqual(needs.bmr, 1730.0)
        XCTAssertEqual(needs.tdee, 2682.0)
        XCTAssertEqual(needs.targetCalories, 2682.0)
        XCTAssertEqual(needs.calorieAdjustment, 0.0)
    }

    func testNutritionNeedsForAthleticMuscleGain() {
        let athleteProfile = UserProfile(
            gender: .male,
            age: 25,
            weight: 80.0,
            height: 185.0,
            activityLevel: .veryActive,
            goal: .muscleGain
        )

        let needs = NutritionCalculator.calculateNeeds(for: athleteProfile)

        XCTAssertEqual(needs.bmr, 1836.0)
        XCTAssertEqual(needs.tdee, 3168.0)
        XCTAssertGreaterThan(needs.targetCalories, needs.tdee)
        XCTAssertGreaterThan(needs.calorieAdjustment, 0.0)

        XCTAssertEqual(needs.proteinsGrams, 176.0)
        XCTAssertEqual(needs.proteinsCalories, 176.0 * 4.0)

        XCTAssertGreaterThan(needs.fatsGrams, 0.0)
        XCTAssertGreaterThan(needs.carbohydratesGrams, needs.proteinsGrams)
        XCTAssertEqual(needs.waterLiters, 3.8)
    }

    func testNutritionNeedsForWeightLossDeficit() {
        let femaleProfile = UserProfile(
            gender: .female,
            age: 32,
            weight: 68.0,
            height: 165.0,
            activityLevel: .moderate,
            goal: .weightLoss
        )

        let needs = NutritionCalculator.calculateNeeds(for: femaleProfile)

        // Caloric deficit must remain bounded above basal metabolic rate
        XCTAssertLessThan(needs.targetCalories, needs.tdee)
        XCTAssertGreaterThanOrEqual(needs.targetCalories, needs.bmr)
        XCTAssertLessThan(needs.calorieAdjustment, 0.0)
        XCTAssertEqual(needs.proteinsGrams, 129.0)
    }

    func testUserProfileGenderBackwardCompatibility() throws {
        // Legacy serialized profile JSON without gender property
        let jsonWithoutGender = """
        {
            "id": "11111111-2222-3333-4444-555555555555",
            "age": 29,
            "weight": 70.0,
            "height": 175.0,
            "activity_level": "moderate",
            "goal": "maintenance",
            "allergies": [],
            "dietary_preferences": [],
            "disliked_ingredients": []
        }
        """
        let data = Data(jsonWithoutGender.utf8)

        let decoded = try JSONDecoder().decode(UserProfile.self, from: data)
        XCTAssertNil(decoded.gender)
        XCTAssertEqual(decoded.age, 29)
        XCTAssertEqual(decoded.weight, 70.0)

        let needs = NutritionCalculator.calculateNeeds(for: decoded)
        XCTAssertGreaterThan(needs.targetCalories, 1000.0)
    }
}
