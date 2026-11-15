@testable import AlgourmandCore
import XCTest

final class ProfileSetupTests: XCTestCase {
    @MainActor
    func testProfileSetupViewModelNavigation() {
        let viewModel = ProfileSetupViewModel()

        XCTAssertEqual(viewModel.currentStep, .physicalInfo)
        XCTAssertEqual(viewModel.currentStepIndex, 0)
        XCTAssertEqual(viewModel.totalSteps, 5)
        XCTAssertFalse(viewModel.canGoBack)
        XCTAssertFalse(viewModel.isLastStep)
        XCTAssertEqual(viewModel.progress, 0.2)

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .physicalInfo)
        XCTAssertFalse(viewModel.canProceedFromCurrentStep)

        viewModel.ageText = "28"
        viewModel.weightText = "72"
        viewModel.heightText = "178"
        XCTAssertTrue(viewModel.canProceedFromCurrentStep)

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .nutritionGoal)
        XCTAssertTrue(viewModel.canGoBack)
        XCTAssertEqual(viewModel.progress, 0.4)

        viewModel.previousStep()
        XCTAssertEqual(viewModel.currentStep, .physicalInfo)
        XCTAssertFalse(viewModel.canGoBack)

        viewModel.nextStep()
        viewModel.nextStep()
        viewModel.nextStep()
        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .dislikedIngredients)
        XCTAssertTrue(viewModel.isLastStep)
        XCTAssertEqual(viewModel.progress, 1.0)

        viewModel.nextStep()
        XCTAssertTrue(viewModel.isCompleted)
    }

    @MainActor
    func testProfileSetupPhysicalInfoValidation() {
        let viewModel = ProfileSetupViewModel()
        XCTAssertEqual(viewModel.currentStep, .physicalInfo)
        XCTAssertFalse(viewModel.isAgeValid)
        XCTAssertFalse(viewModel.isPhysicalInfoValid)
        XCTAssertFalse(viewModel.canProceedFromCurrentStep)
        XCTAssertNotNil(viewModel.physicalInfoValidationError)

        viewModel.ageText = "abc"
        XCTAssertNil(viewModel.ageValue)
        XCTAssertFalse(viewModel.isAgeValid)

        viewModel.ageText = "9"
        XCTAssertFalse(viewModel.isAgeValid)

        viewModel.ageText = "121"
        XCTAssertFalse(viewModel.isAgeValid)

        viewModel.ageText = "28"
        XCTAssertEqual(viewModel.ageValue, 28)
        XCTAssertTrue(viewModel.isAgeValid)
        XCTAssertTrue(viewModel.isWeightValid)
        XCTAssertTrue(viewModel.isHeightValid)
        XCTAssertTrue(viewModel.isPhysicalInfoValid)
        XCTAssertTrue(viewModel.canProceedFromCurrentStep)

        // Decimal formatting supports comma as localized decimal separator
        viewModel.heightText = "178,5"
        viewModel.weightText = "72,4"
        XCTAssertEqual(viewModel.heightValue, 178.5)
        XCTAssertEqual(viewModel.weightValue, 72.4)
        XCTAssertTrue(viewModel.isHeightValid)
        XCTAssertTrue(viewModel.isWeightValid)
        XCTAssertTrue(viewModel.isPhysicalInfoValid)

        viewModel.weightText = "10"
        XCTAssertFalse(viewModel.isWeightValid)
        XCTAssertFalse(viewModel.canProceedFromCurrentStep)

        viewModel.weightText = "72,4"
        XCTAssertTrue(viewModel.canProceedFromCurrentStep)

        viewModel.activityLevel = .veryActive
        XCTAssertEqual(viewModel.activityLevel, .veryActive)

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .nutritionGoal)

        XCTAssertEqual(viewModel.nutritionGoal, .maintenance)
        XCTAssertTrue(viewModel.canProceedFromCurrentStep)

        viewModel.nutritionGoal = .weightLoss
        XCTAssertEqual(viewModel.nutritionGoal, .weightLoss)

        for goal in UserProfile.NutritionGoal.allCases {
            XCTAssertFalse(goal.displayName.isEmpty)
            XCTAssertFalse(goal.subtitle.isEmpty)
            XCTAssertFalse(goal.systemIcon.isEmpty)
        }

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .dietaryPreferences)
        viewModel.toggleDietaryPreference("vegetarian")
        XCTAssertTrue(viewModel.isDietaryPreferenceSelected("vegetarian"))
        viewModel.toggleDietaryPreference("vegetarian")
        XCTAssertFalse(viewModel.isDietaryPreferenceSelected("vegetarian"))
        viewModel.toggleDietaryPreference("omnivore")

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .allergies)
        viewModel.toggleAllergy("gluten")
        viewModel.toggleAllergy("peanuts")
        XCTAssertTrue(viewModel.isAllergySelected("gluten"))
        XCTAssertTrue(viewModel.isAllergySelected("peanuts"))
        XCTAssertFalse(viewModel.isAllergySelected("lactose"))
        viewModel.clearAllergies()
        XCTAssertFalse(viewModel.isAllergySelected("gluten"))
        viewModel.toggleAllergy("peanuts")

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .dislikedIngredients)
        XCTAssertTrue(viewModel.isLastStep)
        viewModel.addDislikedIngredient("Coriandre")
        viewModel.addDislikedIngredient("Céleri")
        viewModel.addDislikedIngredient("coriandre")
        XCTAssertEqual(viewModel.dislikedIngredients.count, 2)
        viewModel.removeDislikedIngredient("Céleri")
        XCTAssertEqual(viewModel.dislikedIngredients, ["Coriandre"])

        viewModel.nextStep()
        XCTAssertTrue(viewModel.isCompleted)

        let profile = viewModel.buildUserProfile()
        XCTAssertEqual(profile.age, 28)
        XCTAssertEqual(profile.height, 178.5)
        XCTAssertEqual(profile.weight, 72.4)
        XCTAssertEqual(profile.activityLevel, .veryActive)
        XCTAssertEqual(profile.goal, .weightLoss)
        XCTAssertEqual(profile.dietaryPreferences, ["omnivore"])
        XCTAssertEqual(profile.allergies, ["peanuts"])
        XCTAssertEqual(profile.dislikedIngredients, ["Coriandre"])
    }
}
