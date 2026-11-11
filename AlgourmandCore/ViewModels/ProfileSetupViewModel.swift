import Combine
import Foundation

@MainActor
public final class ProfileSetupViewModel: ObservableObject {
    public enum Step: Int, CaseIterable, Identifiable, Sendable {
        case physicalInfo = 0
        case nutritionGoal = 1
        case dietaryPreferences = 2
        case allergies = 3
        case dislikedIngredients = 4

        public var id: Int { rawValue }

        public var title: String {
            switch self {
            case .physicalInfo:
                return "Vos mensurations"
            case .nutritionGoal:
                return "Votre objectif"
            case .dietaryPreferences:
                return "Votre régime"
            case .allergies:
                return "Allergies & intolérances"
            case .dislikedIngredients:
                return "Aliments détestés"
            }
        }

        public var subtitle: String {
            switch self {
            case .physicalInfo:
                return "Renseignez votre âge, taille et poids pour adapter vos besoins énergétiques."
            case .nutritionGoal:
                return "Définissez le cap nutritionnel que vous souhaitez atteindre au quotidien."
            case .dietaryPreferences:
                return "Sélectionnez vos préférences et habitudes alimentaires principales."
            case .allergies:
                return "Indiquez les ingrédients à exclure strictement de vos recettes."
            case .dislikedIngredients:
                return "Précisez vos aversions pour des suggestions de repas sur mesure."
            }
        }

        public var systemIcon: String {
            switch self {
            case .physicalInfo:
                return "figure.arms.open"
            case .nutritionGoal:
                return "target"
            case .dietaryPreferences:
                return "leaf.fill"
            case .allergies:
                return "exclamationmark.shield.fill"
            case .dislikedIngredients:
                return "hand.thumbsdown.fill"
            }
        }
    }

    // MARK: - Navigation State
    @Published public var currentStep: Step = .physicalInfo
    @Published public var isCompleted: Bool = false

    // MARK: - Form Data
    @Published public var ageText: String = ""
    @Published public var weightText: String = ""
    @Published public var heightText: String = ""
    @Published public var activityLevel: UserProfile.ActivityLevel = .moderate
    @Published public var nutritionGoal: UserProfile.NutritionGoal = .maintenance
    @Published public var selectedDietaryPreferences: Set<String> = []
    @Published public var selectedAllergies: Set<String> = []
    @Published public var dislikedIngredients: [String] = []

    // MARK: - Validation & Parsed Values
    // PhysicalInfo
    public var ageValue: Int? {
        let cleaned = ageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Int(cleaned) else { return nil }
        return value
    }

    public var weightValue: Double? {
        let cleaned = weightText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard !cleaned.isEmpty else { return nil }
        return Double(cleaned)
    }

    public var heightValue: Double? {
        let cleaned = heightText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard !cleaned.isEmpty else { return nil }
        return Double(cleaned)
    }

    public var isAgeValid: Bool {
        guard let age = ageValue else { return false }
        return age >= 10 && age <= 120
    }

    public var isWeightValid: Bool {
        let cleaned = weightText.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.isEmpty { return true }
        guard let weight = weightValue else { return false }
        return weight >= 20.0 && weight <= 350.0
    }

    public var isHeightValid: Bool {
        let cleaned = heightText.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.isEmpty { return true }
        guard let height = heightValue else { return false }
        return height >= 50.0 && height <= 260.0
    }

    public var isPhysicalInfoValid: Bool {
        isAgeValid && isWeightValid && isHeightValid
    }

    public var canProceedFromCurrentStep: Bool {
        switch currentStep {
        case .physicalInfo:
            return isPhysicalInfoValid
        case .nutritionGoal, .dietaryPreferences, .allergies, .dislikedIngredients:
            return true
        }
    }

    public var physicalInfoValidationError: String? {
        let cleanedAge = ageText.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedAge.isEmpty {
            return "L'âge est requis pour calculer vos besoins nutritionnels."
        }
        if !isAgeValid {
            return "Veuillez saisir un âge valide (entre 10 et 120 ans)."
        }
        if !isHeightValid {
            return "Veuillez saisir une taille valide (entre 50 et 260 cm)."
        }
        if !isWeightValid {
            return "Veuillez saisir un poids valide (entre 20 et 350 kg)."
        }
        return nil
    }

    // MARK: - Step
    public let totalSteps: Int = Step.allCases.count

    public var currentStepIndex: Int {
        currentStep.rawValue
    }

    public var progress: Double {
        Double(currentStep.rawValue + 1) / Double(totalSteps)
    }

    public var canGoBack: Bool {
        currentStep.rawValue > 0
    }

    public var isLastStep: Bool {
        currentStep.rawValue == totalSteps - 1
    }

    public init() {}

    public func nextStep() {
        guard canProceedFromCurrentStep else { return }
        if let next = Step(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        } else {
            completeSetup()
        }
    }

    public func previousStep() {
        if let previous = Step(rawValue: currentStep.rawValue - 1) {
            currentStep = previous
        }
    }

    public func completeSetup() {
        isCompleted = true
    }
}
