import Foundation

public protocol RecipeFilterServiceProtocol: Sendable {
    func isRecipeAllergyFree(_ recipe: Recipe, allergies: [String]) -> Bool
    func isRecipeDietaryCompliant(_ recipe: Recipe, dietaryPreferences: [String]) -> Bool
    func isRecipeFreeFromDisliked(_ recipe: Recipe, dislikedIngredients: [String]) -> Bool
    func isRecipePrepTimeCompliant(_ recipe: Recipe, maxPreparationTime: Int?) -> Bool
    func filterRecipes(
        _ recipes: [Recipe],
        profile: UserProfile,
        preferences: WeeklyPreferences?
    ) -> [Recipe]
    func scoreRecipe(
        _ recipe: Recipe,
        preferences: WeeklyPreferences?
    ) -> Double
}

public struct RecipeFilterService: RecipeFilterServiceProtocol {
    public static let shared = RecipeFilterService()

    public init() {}

    // MARK: - Allergen Keywords Mapping
    private let allergenKeywords: [String: [String]] = [
        "gluten": [
            "gluten", "wheat", "flour", "pasta", "spaghetti", "bread",
            "semolina", "couscous", "noodle", "barley", "rye", "oat",
            "ble", "farine", "pate", "pates", "pain", "semoule", "seigle", "orge", "avoine"
        ],
        "lactose": [
            "milk", "lactose", "butter", "cheese", "cream", "parmesan",
            "cheddar", "mozzarella", "yogurt", "yoghurt", "whey", "ricotta",
            "mascarpone", "lait", "beurre", "fromage", "creme", "yaourt", "gruyere", "emmental"
        ],
        "peanuts": [
            "peanut", "peanuts", "arachide", "arachides", "cacahuete", "cacahuetes"
        ],
        "tree_nuts": [
            "nut", "nuts", "walnut", "almond", "cashew", "hazelnut", "pistachio",
            "pecan", "noix", "amande", "noisette", "cajou", "pistache", "pecan"
        ],
        "eggs": [
            "egg", "eggs", "mayonnaise", "oeuf", "oeufs"
        ],
        "fish": [
            "fish", "salmon", "tuna", "cod", "trout", "sardine", "anchovy", "halibut",
            "poisson", "saumon", "thon", "cabillaud", "truite", "colin"
        ],
        "crustaceans": [
            "shrimp", "prawn", "crab", "lobster", "mussel", "clam", "oyster", "squid",
            "octopus", "crevette", "crabe", "homard", "moule", "huitre", "calmar"
        ],
        "soy": [
            "soy", "soya", "tofu", "edamame", "soja"
        ],
        "sesame": [
            "sesame", "tahini"
        ],
        "mustard": [
            "mustard", "moutarde", "dijon"
        ],
        "celery": [
            "celery", "celeriac", "celeri"
        ]
    ]

    private let landMeatKeywords: [String] = [
        "beef", "pork", "bacon", "ham", "sausage", "chicken", "lamb", "duck",
        "turkey", "meat", "steak", "veal", "goat", "mutton",
        "boeuf", "porc", "poulet", "dinde", "canard", "agneau", "veau", "lardon", "jambon", "saucisse", "viande"
    ]

    private let seafoodKeywords: [String] = [
        "fish", "salmon", "tuna", "cod", "trout", "shrimp", "prawn", "crab",
        "lobster", "seafood", "mussel", "clam", "oyster",
        "poisson", "saumon", "thon", "crevette", "crabe", "homard", "moule", "huitre"
    ]

    private let animalDerivativeKeywords: [String] = [
        "milk", "butter", "cheese", "cream", "yogurt", "egg", "eggs", "honey",
        "lait", "beurre", "fromage", "creme", "yaourt", "oeuf", "miel"
    ]

    private let plantBasedMilkAndCreamExceptions: [String] = [
        "lait de coco", "coconut milk", "lait d'amande", "almond milk",
        "lait de soja", "soya milk", "soy milk", "lait d'avoine", "oat milk",
        "creme de coco", "coconut cream", "beurre de cacahuete", "peanut butter"
    ]

    // MARK: - Allergies & Dietary Restrictions
    public func isRecipeAllergyFree(_ recipe: Recipe, allergies: [String]) -> Bool {
        guard !allergies.isEmpty else { return true }

        let ingredientNames = recipe.ingredients.map { normalize($0.name) }
        let recipeName = normalize(recipe.name)

        for allergy in allergies {
            let key = normalize(allergy)
            let keywords = allergenKeywords[key] ?? [key]

            for keyword in keywords {
                let matchesIngredient = ingredientNames.contains { name in
                    if key == "lactose" && isPlantBasedException(name) {
                        return false
                    }
                    return name.contains(keyword)
                }
                let matchesRecipeName = recipeName.contains(keyword) && !(key == "lactose" && isPlantBasedException(recipeName))
                if matchesIngredient || matchesRecipeName {
                    return false
                }
            }
        }
        return true
    }

    public func isRecipeDietaryCompliant(_ recipe: Recipe, dietaryPreferences: [String]) -> Bool {
        guard !dietaryPreferences.isEmpty else { return true }

        let activePreferences = Set(dietaryPreferences.map { normalize($0) })
        if activePreferences.contains("omnivore") && activePreferences.count == 1 {
            return true
        }

        let category = normalize(recipe.category)
        let ingredientNames = recipe.ingredients.map { normalize($0.name) }
        let recipeName = normalize(recipe.name)

        let containsLandMeat = categoryContainsLandMeat(category) ||
            ingredientNames.contains(where: containsLandMeatKeyword) ||
            containsLandMeatKeyword(recipeName)

        let containsSeafood = category.contains("seafood") ||
            ingredientNames.contains(where: containsSeafoodKeyword) ||
            containsSeafoodKeyword(recipeName)

        if activePreferences.contains("vegetarian") {
            if containsLandMeat || containsSeafood {
                return false
            }
        }

        if activePreferences.contains("vegan") {
            if containsLandMeat || containsSeafood {
                return false
            }
            let containsAnimalProducts = ingredientNames.contains(where: containsAnimalDerivativeKeyword) ||
                containsAnimalDerivativeKeyword(recipeName)
            if containsAnimalProducts {
                return false
            }
        }

        if activePreferences.contains("pescatarian") {
            if containsLandMeat {
                return false
            }
        }

        if activePreferences.contains("keto") {
            if recipe.carbohydrates > 25.0 || category.contains("pasta") || category.contains("dessert") {
                return false
            }
        }

        return true
    }

    public func isRecipeFreeFromDisliked(_ recipe: Recipe, dislikedIngredients: [String]) -> Bool {
        guard !dislikedIngredients.isEmpty else { return true }

        let ingredientNames = recipe.ingredients.map { normalize($0.name) }
        let recipeName = normalize(recipe.name)

        for disliked in dislikedIngredients {
            let term = normalize(disliked)
            guard !term.isEmpty else { continue }

            if recipeName.contains(term) || ingredientNames.contains(where: { $0.contains(term) }) {
                return false
            }
        }
        return true
    }

    // MARK: - Preferences & Preparation Time
    public func isRecipePrepTimeCompliant(_ recipe: Recipe, maxPreparationTime: Int?) -> Bool {
        guard let maxTime = maxPreparationTime, maxTime > 0 else {
            return true
        }
        return recipe.preparationTime <= maxTime
    }

    public func scoreRecipe(_ recipe: Recipe, preferences: WeeklyPreferences?) -> Double {
        guard let preferences = preferences else { return 1.0 }

        var score: Double = 1.0

        // Preferred cuisines boost
        let normalizedArea = normalize(recipe.area ?? "")
        let normalizedTags = recipe.tags.map { normalize($0) }
        let normalizedCategory = normalize(recipe.category)

        for pref in preferences.preferences {
            let p = normalize(pref)
            if normalizedArea.contains(p) ||
               normalizedCategory.contains(p) ||
               normalizedTags.contains(where: { $0.contains(p) }) ||
               isCuisineMatch(preferred: p, recipeArea: normalizedArea) {
                score += 3.0
            }
        }

        // Available ingredients match (anti-waste)
        let ingredientNames = recipe.ingredients.map { normalize($0.name) }
        for available in preferences.availableIngredients {
            let term = normalize(available)
            guard !term.isEmpty else { continue }
            if ingredientNames.contains(where: { $0.contains(term) }) {
                score += 2.0
            }
        }

        return score
    }

    public func filterRecipes(
        _ recipes: [Recipe],
        profile: UserProfile,
        preferences: WeeklyPreferences?
    ) -> [Recipe] {
        let maxPrepTime = preferences?.maxPreparationTime

        return recipes
            .filter { recipe in
                isRecipeAllergyFree(recipe, allergies: profile.allergies) &&
                isRecipeDietaryCompliant(recipe, dietaryPreferences: profile.dietaryPreferences) &&
                isRecipeFreeFromDisliked(recipe, dislikedIngredients: profile.dislikedIngredients) &&
                isRecipePrepTimeCompliant(recipe, maxPreparationTime: maxPrepTime)
            }
            .sorted { lhs, rhs -> Bool in
                let scoreLhs = scoreRecipe(lhs, preferences: preferences)
                let scoreRhs = scoreRecipe(rhs, preferences: preferences)
                if scoreLhs != scoreRhs {
                    return scoreLhs > scoreRhs
                }
                return lhs.name < rhs.name
            }
    }

    // MARK: - Private Helpers
    private func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
    }

    private func containsLandMeatKeyword(_ text: String) -> Bool {
        landMeatKeywords.contains { text.contains($0) }
    }

    private func containsSeafoodKeyword(_ text: String) -> Bool {
        seafoodKeywords.contains { text.contains($0) }
    }

    private func isPlantBasedException(_ text: String) -> Bool {
        plantBasedMilkAndCreamExceptions.contains { text.contains($0) }
    }

    private func containsAnimalDerivativeKeyword(_ text: String) -> Bool {
        if isPlantBasedException(text) {
            return false
        }
        return animalDerivativeKeywords.contains { text.contains($0) }
    }

    private func categoryContainsLandMeat(_ category: String) -> Bool {
        ["beef", "chicken", "lamb", "pork", "goat"].contains { category.contains($0) }
    }

    private func isCuisineMatch(preferred: String, recipeArea: String) -> Bool {
        switch preferred {
        case "italienne", "italien":
            return recipeArea.contains("italian")
        case "francaise", "francais":
            return recipeArea.contains("french")
        case "asiatique":
            return ["chinese", "japanese", "thai", "vietnamese", "indian"].contains { recipeArea.contains($0) }
        case "mexicaine", "mexicain":
            return recipeArea.contains("mexican")
        case "mediterraneenne":
            return ["greek", "italian", "spanish", "moroccan"].contains { recipeArea.contains($0) }
        case "americaine":
            return recipeArea.contains("american")
        case "indienne":
            return recipeArea.contains("indian")
        case "japonaise":
            return recipeArea.contains("japanese")
        default:
            return recipeArea.contains(preferred)
        }
    }
}
