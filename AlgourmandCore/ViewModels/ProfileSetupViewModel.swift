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
    @Published public var dislikedIngredientInput: String = ""

    // MARK: - Predefined Catalogues
    public struct OptionItem: Identifiable, Hashable, Sendable {
        public let id: String
        public let title: String
        public let subtitle: String?
        public let systemIcon: String

        public init(id: String, title: String, subtitle: String? = nil, systemIcon: String) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
            self.systemIcon = systemIcon
        }
    }

    public let availableDietaryPreferences: [OptionItem] = [
        OptionItem(
            id: "omnivore",
            title: "Omnivore",
            subtitle: "Aucune restriction, tout me convient",
            systemIcon: "fork.knife"
        ),
        OptionItem(
            id: "vegetarian",
            title: "Végétarien",
            subtitle: "Sans viande ni poisson",
            systemIcon: "leaf.fill"
        ),
        OptionItem(
            id: "vegan",
            title: "Végétalien / Végan",
            subtitle: "100% végétal, aucun produit animal",
            systemIcon: "carrot.fill"
        ),
        OptionItem(
            id: "pescatarian",
            title: "Pescétarien",
            subtitle: "Végétarien avec poissons et fruits de mer",
            systemIcon: "fish.fill"
        ),
        OptionItem(
            id: "flexitarian",
            title: "Flexitarien",
            subtitle: "Principalement végétal, viande occasionnelle",
            systemIcon: "arrow.3.trianglepath"
        ),
        OptionItem(
            id: "keto",
            title: "Cétogène (Keto)",
            subtitle: "Riche en bons lipides, très pauvre en glucides",
            systemIcon: "flame"
        )
    ]

    public let availableAllergies: [OptionItem] = [
        OptionItem(id: "gluten", title: "Gluten / Blé", systemIcon: "cross.case.fill"),
        OptionItem(id: "lactose", title: "Lactose / Produits laitiers", systemIcon: "cup.and.saucer.fill"),
        OptionItem(id: "peanuts", title: "Arachides", systemIcon: "allergens"),
        OptionItem(id: "tree_nuts", title: "Fruits à coque", systemIcon: "leaf"),
        OptionItem(id: "eggs", title: "Œufs", systemIcon: "oval.fill"),
        OptionItem(id: "fish", title: "Poissons", systemIcon: "fish.fill"),
        OptionItem(id: "crustaceans", title: "Crustacés & Mollusques", systemIcon: "water.waves"),
        OptionItem(id: "soy", title: "Soja", systemIcon: "drop.fill"),
        OptionItem(id: "sesame", title: "Sésame", systemIcon: "circle.grid.2x2.fill"),
        OptionItem(id: "mustard", title: "Moutarde", systemIcon: "takeoutbag.and.cup.and.straw.fill"),
        OptionItem(id: "celery", title: "Céleri", systemIcon: "camera.macro")
    ]

    public let popularDislikedSuggestions: [String] = [
        "Coriandre", "Céleri", "Choux de Bruxelles", "Champignons",
        "Aubergines", "Foie", "Poivrons", "Olives", "Brocolis", "Huîtres"
    ]

    // MARK: - Form Actions
    public func toggleDietaryPreference(_ id: String) {
        if selectedDietaryPreferences.contains(id) {
            selectedDietaryPreferences.remove(id)
        } else {
            selectedDietaryPreferences.insert(id)
        }
    }

    public func isDietaryPreferenceSelected(_ id: String) -> Bool {
        selectedDietaryPreferences.contains(id)
    }

    public func toggleAllergy(_ id: String) {
        if selectedAllergies.contains(id) {
            selectedAllergies.remove(id)
        } else {
            selectedAllergies.insert(id)
        }
    }

    public func isAllergySelected(_ id: String) -> Bool {
        selectedAllergies.contains(id)
    }

    public func clearAllergies() {
        selectedAllergies.removeAll()
    }

    public func addDislikedIngredient(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !dislikedIngredients.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            dislikedIngredients.append(trimmed)
        }
        dislikedIngredientInput = ""
    }

    public func removeDislikedIngredient(_ name: String) {
        dislikedIngredients.removeAll { $0.caseInsensitiveCompare(name) == .orderedSame }
    }

    // MARK: - Validation & Parsed Values
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

    public func buildUserProfile(id: UUID = UUID()) -> UserProfile {
        UserProfile(
            id: id,
            age: ageValue ?? 25,
            weight: weightValue,
            height: heightValue,
            activityLevel: activityLevel,
            goal: nutritionGoal,
            allergies: Array(selectedAllergies),
            dietaryPreferences: Array(selectedDietaryPreferences),
            dislikedIngredients: dislikedIngredients
        )
    }
}
