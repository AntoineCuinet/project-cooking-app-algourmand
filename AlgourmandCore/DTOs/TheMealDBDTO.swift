import Foundation

// MARK: - Root Responses
public struct TheMealDBResponseDTO: Codable, Sendable {
    public let meals: [TheMealDBMealDTO]?

    public init(meals: [TheMealDBMealDTO]?) {
        self.meals = meals
    }
}

public struct TheMealDBCategoriesResponseDTO: Codable, Sendable {
    public let categories: [TheMealDBCategoryDTO]?

    public init(categories: [TheMealDBCategoryDTO]?) {
        self.categories = categories
    }
}

public struct TheMealDBCategoryDTO: Codable, Sendable {
    public let idCategory: String
    public let strCategory: String
    public let strCategoryThumb: String?
    public let strCategoryDescription: String?

    public init(
        idCategory: String,
        strCategory: String,
        strCategoryThumb: String? = nil,
        strCategoryDescription: String? = nil
    ) {
        self.idCategory = idCategory
        self.strCategory = strCategory
        self.strCategoryThumb = strCategoryThumb
        self.strCategoryDescription = strCategoryDescription
    }
}

// MARK: - Meal DTO
public struct TheMealDBMealDTO: Codable, Sendable {
    public let idMeal: String
    public let strMeal: String
    public let strCategory: String?
    public let strArea: String?
    public let strInstructions: String?
    public let strMealThumb: String?
    public let strTags: String?
    public let strYoutube: String?
    public let ingredientsWithMeasures: [(ingredient: String, measure: String)]

    private struct DynamicKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int? { nil }
        init?(intValue: Int) { nil }
    }

    public init(
        idMeal: String,
        strMeal: String,
        strCategory: String? = nil,
        strArea: String? = nil,
        strInstructions: String? = nil,
        strMealThumb: String? = nil,
        strTags: String? = nil,
        strYoutube: String? = nil,
        ingredientsWithMeasures: [(ingredient: String, measure: String)] = []
    ) {
        self.idMeal = idMeal
        self.strMeal = strMeal
        self.strCategory = strCategory
        self.strArea = strArea
        self.strInstructions = strInstructions
        self.strMealThumb = strMealThumb
        self.strTags = strTags
        self.strYoutube = strYoutube
        self.ingredientsWithMeasures = ingredientsWithMeasures
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)

        self.idMeal = try container.decode(String.self, forKey: DynamicKey(stringValue: "idMeal")!)
        self.strMeal = try container.decode(String.self, forKey: DynamicKey(stringValue: "strMeal")!)
        self.strCategory = try container.decodeIfPresent(String.self, forKey: DynamicKey(stringValue: "strCategory")!)
        self.strArea = try container.decodeIfPresent(String.self, forKey: DynamicKey(stringValue: "strArea")!)
        self.strInstructions = try container.decodeIfPresent(
            String.self,
            forKey: DynamicKey(stringValue: "strInstructions")!
        )
        self.strMealThumb = try container.decodeIfPresent(
            String.self,
            forKey: DynamicKey(stringValue: "strMealThumb")!
        )
        self.strTags = try container.decodeIfPresent(String.self, forKey: DynamicKey(stringValue: "strTags")!)
        self.strYoutube = try container.decodeIfPresent(String.self, forKey: DynamicKey(stringValue: "strYoutube")!)

        var pairs: [(ingredient: String, measure: String)] = []
        for index in 1...20 {
            guard let ingKey = DynamicKey(stringValue: "strIngredient\(index)"),
                  let measureKey = DynamicKey(stringValue: "strMeasure\(index)") else {
                continue
            }

            if let ingredient = try? container.decodeIfPresent(String.self, forKey: ingKey) {
                let trimmedIngredient = ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedIngredient.isEmpty {
                    let measure = (try? container.decodeIfPresent(String.self, forKey: measureKey))?
                        .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    pairs.append((ingredient: trimmedIngredient, measure: measure))
                }
            }
        }
        self.ingredientsWithMeasures = pairs
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        try container.encode(idMeal, forKey: DynamicKey(stringValue: "idMeal")!)
        try container.encode(strMeal, forKey: DynamicKey(stringValue: "strMeal")!)
        try container.encodeIfPresent(strCategory, forKey: DynamicKey(stringValue: "strCategory")!)
        try container.encodeIfPresent(strArea, forKey: DynamicKey(stringValue: "strArea")!)
        try container.encodeIfPresent(strInstructions, forKey: DynamicKey(stringValue: "strInstructions")!)
        try container.encodeIfPresent(strMealThumb, forKey: DynamicKey(stringValue: "strMealThumb")!)
        try container.encodeIfPresent(strTags, forKey: DynamicKey(stringValue: "strTags")!)
        try container.encodeIfPresent(strYoutube, forKey: DynamicKey(stringValue: "strYoutube")!)

        for (index, pair) in ingredientsWithMeasures.prefix(20).enumerated() {
            let num = index + 1
            if let ingKey = DynamicKey(stringValue: "strIngredient\(num)"),
               let measureKey = DynamicKey(stringValue: "strMeasure\(num)") {
                try container.encode(pair.ingredient, forKey: ingKey)
                try container.encode(pair.measure, forKey: measureKey)
            }
        }
    }

    // MARK: - Domain Mapping
    public func toDomain() -> Recipe {
        let domainIngredients = ingredientsWithMeasures.map { pair -> Ingredient in
            let parsed = Self.parseMeasure(pair.measure)
            return Ingredient(
                id: UUID(),
                name: pair.ingredient.capitalized,
                quantity: parsed.quantity,
                unit: parsed.unit
            )
        }

        let instructionsList = Self.parseInstructions(strInstructions ?? "")
        let tagsList = strTags?
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? []

        let estimatedPrepTime = Self.estimatePrepTime(
            category: strCategory,
            ingredientsCount: domainIngredients.count
        )
        let nutritionalMacros = Self.estimateMacros(category: strCategory)

        return Recipe(
            id: Self.makeDeterministicUUID(from: idMeal),
            externalId: idMeal,
            name: strMeal,
            image: strMealThumb,
            category: strCategory ?? "Plat",
            area: strArea,
            ingredients: domainIngredients,
            instructions: instructionsList,
            preparationTime: estimatedPrepTime,
            calories: nutritionalMacros.calories,
            proteins: nutritionalMacros.proteins,
            carbohydrates: nutritionalMacros.carbohydrates,
            fats: nutritionalMacros.fats,
            tags: tagsList,
            youtubeURL: strYoutube
        )
    }

    // MARK: - Helpers
    public static func makeDeterministicUUID(from idString: String) -> UUID {
        if let intId = Int(idString) {
            let formatted = String(format: "00000000-0000-0000-0000-%012d", intId)
            if let uuid = UUID(uuidString: formatted) {
                return uuid
            }
        }
        let hash = abs(idString.hashValue)
        let formatted = String(format: "00000000-0000-0000-0000-%012ld", hash % 1_000_000_000_000)
        return UUID(uuidString: formatted) ?? UUID()
    }

    public static func parseInstructions(_ text: String) -> [String] {
        text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { line -> String in
                // Clean prefix like "STEP 1 - " or "1. "
                if let range = line.range(of: #"^(\d+\.|\bstep\s*\d+[:.-]?)\s*"#, options: [.regularExpression, .caseInsensitive]) {
                    var cleaned = line
                    cleaned.removeSubrange(range)
                    return cleaned
                }
                return line
            }
            .filter { !$0.isEmpty }
    }

    public static func parseMeasure(_ measure: String) -> (quantity: Double, unit: String) {
        let cleaned = measure.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return (1.0, "portion") }

        let fractionMap: [String: Double] = [
            "1/2": 0.5, "1/3": 0.33, "2/3": 0.66,
            "1/4": 0.25, "3/4": 0.75, "1/8": 0.125
        ]

        for (fraction, val) in fractionMap where cleaned.hasPrefix(fraction) {
            let remaining = cleaned.dropFirst(fraction.count).trimmingCharacters(in: .whitespaces)
            return (val, remaining.isEmpty ? "portion" : remaining)
        }

        let scanner = Scanner(string: cleaned)
        if let number = scanner.scanDouble() {
            let remaining = String(cleaned[scanner.currentIndex...]).trimmingCharacters(in: .whitespaces)
            return (number, remaining.isEmpty ? "portion" : remaining)
        }

        return (1.0, cleaned)
    }

    public static func estimatePrepTime(category: String?, ingredientsCount: Int) -> Int {
        let baseTime: Int
        switch category?.lowercased() {
        case "dessert": baseTime = 35
        case "starter", "side": baseTime = 15
        case "pasta": baseTime = 20
        case "seafood": baseTime = 25
        case "beef", "lamb", "pork": baseTime = 45
        default: baseTime = 30
        }
        let total = baseTime + (ingredientsCount * 2)
        return min(90, max(15, (total / 5) * 5))
    }

    public struct NutritionalValues: Sendable {
        public let calories: Double
        public let proteins: Double
        public let carbohydrates: Double
        public let fats: Double

        public init(calories: Double, proteins: Double, carbohydrates: Double, fats: Double) {
            self.calories = calories
            self.proteins = proteins
            self.carbohydrates = carbohydrates
            self.fats = fats
        }
    }

    public static func estimateMacros(category: String?) -> NutritionalValues {
        switch category?.lowercased() {
        case "dessert":
            return NutritionalValues(calories: 390, proteins: 5, carbohydrates: 58, fats: 16)
        case "vegetarian", "vegan":
            return NutritionalValues(calories: 360, proteins: 14, carbohydrates: 48, fats: 11)
        case "seafood":
            return NutritionalValues(calories: 410, proteins: 32, carbohydrates: 26, fats: 12)
        case "chicken":
            return NutritionalValues(calories: 480, proteins: 38, carbohydrates: 34, fats: 14)
        case "beef", "lamb", "pork":
            return NutritionalValues(calories: 560, proteins: 36, carbohydrates: 30, fats: 26)
        case "pasta":
            return NutritionalValues(calories: 520, proteins: 16, carbohydrates: 68, fats: 18)
        default:
            return NutritionalValues(calories: 450, proteins: 24, carbohydrates: 42, fats: 15)
        }
    }
}
