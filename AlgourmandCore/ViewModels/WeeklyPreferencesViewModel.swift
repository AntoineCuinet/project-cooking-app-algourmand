import Combine
import Foundation

@MainActor
public final class WeeklyPreferencesViewModel: ObservableObject {
    // MARK: - Form State
    @Published public var budget: Double = 80.0
    @Published public var numberOfPeople: Int = 2
    @Published public var dailyCalories: Int = 2000
    @Published public var maxPreparationTime: Int = 30
    @Published public var hasNoTimeLimit: Bool = false
    @Published public var selectedCuisines: Set<String> = ["Méditerranéenne", "Rapide & Simple"]
    @Published public var availableIngredients: [String] = []
    @Published public var ingredientInput: String = ""

    // MARK: - Feedback State
    @Published public var isSaved: Bool = false
    @Published public var feedbackMessage: String?

    // MARK: - Available Options
    public let availableCuisines: [String] = [
        "Italienne", "Française", "Asiatique", "Méditerranéenne",
        "Mexicaine", "Végétarienne", "Rapide & Simple", "Plats mijotés",
        "Street Food saine", "Bistrot"
    ]

    public let prepTimePresets: [Int] = [15, 25, 35, 45, 60]

    private let storage: LocalWeeklyPreferencesStorage

    public init(storage: LocalWeeklyPreferencesStorage = .shared) {
        self.storage = storage
    }

    // MARK: - Logic
    public func loadExistingPreferences(for userId: UUID) {
        guard let saved = storage.loadPreferences(for: userId) else { return }
        self.budget = saved.budget
        self.numberOfPeople = saved.numberOfPeople
        self.dailyCalories = saved.dailyCalories
        if let maxTime = saved.maxPreparationTime {
            self.maxPreparationTime = maxTime
            self.hasNoTimeLimit = false
        } else {
            self.hasNoTimeLimit = true
        }
        self.selectedCuisines = Set(saved.preferences)
        self.availableIngredients = saved.availableIngredients
    }

    public func toggleCuisine(_ cuisine: String) {
        if selectedCuisines.contains(cuisine) {
            selectedCuisines.remove(cuisine)
        } else {
            selectedCuisines.insert(cuisine)
        }
    }

    public func isCuisineSelected(_ cuisine: String) -> Bool {
        selectedCuisines.contains(cuisine)
    }

    public func addIngredient(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !availableIngredients.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            availableIngredients.append(trimmed)
        }
        ingredientInput = ""
    }

    public func removeIngredient(_ name: String) {
        availableIngredients.removeAll { $0.caseInsensitiveCompare(name) == .orderedSame }
    }

    public func buildPreferences(id: UUID = UUID()) -> WeeklyPreferences {
        WeeklyPreferences(
            id: id,
            budget: budget,
            dailyCalories: dailyCalories,
            maxPreparationTime: hasNoTimeLimit ? nil : maxPreparationTime,
            preferences: Array(selectedCuisines),
            availableIngredients: availableIngredients,
            numberOfPeople: numberOfPeople
        )
    }

    @discardableResult
    public func savePreferences(for userId: UUID) -> Bool {
        let prefs = buildPreferences()
        let success = storage.savePreferences(prefs, for: userId)
        if success {
            self.isSaved = true
            self.feedbackMessage = "Préférences enregistrées pour votre semaine !"
        }
        return success
    }
}
