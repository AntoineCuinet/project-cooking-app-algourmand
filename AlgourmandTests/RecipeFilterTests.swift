@testable import AlgourmandCore
import XCTest

final class RecipeFilterTests: XCTestCase {
    private let filterService = RecipeFilterService.shared

    func testAllergyFilteringExcludesMatchingIngredients() {
        let pastaWithCheese = Recipe(
            name: "Pâtes au parmesan",
            category: "Pasta",
            ingredients: [
                Ingredient(name: "Pâtes de blé", quantity: 150, unit: "g"),
                Ingredient(name: "Parmesan râpé", quantity: 40, unit: "g"),
                Ingredient(name: "Crème fraîche", quantity: 50, unit: "ml")
            ]
        )

        // Gluten allergy must exclude wheat pasta
        XCTAssertFalse(filterService.isRecipeAllergyFree(pastaWithCheese, allergies: ["gluten"]))

        // Lactose allergy must exclude cheese and cream
        XCTAssertFalse(filterService.isRecipeAllergyFree(pastaWithCheese, allergies: ["lactose"]))

        // Peanuts allergy should not exclude this recipe
        XCTAssertTrue(filterService.isRecipeAllergyFree(pastaWithCheese, allergies: ["peanuts"]))
    }

    func testDietaryFilteringVegetarianAndVeganRestrictions() {
        let chickenSalad = Recipe(
            name: "Salade César",
            category: "Chicken",
            ingredients: [
                Ingredient(name: "Blanc de poulet", quantity: 200, unit: "g"),
                Ingredient(name: "Salade romaine", quantity: 100, unit: "g")
            ]
        )

        let grilledSalmon = Recipe(
            name: "Saumon grillé",
            category: "Seafood",
            ingredients: [
                Ingredient(name: "Pavé de saumon", quantity: 180, unit: "g")
            ]
        )

        let veganCurry = Recipe(
            name: "Dahl de lentilles",
            category: "Vegetarian",
            ingredients: [
                Ingredient(name: "Lentilles corail", quantity: 150, unit: "g"),
                Ingredient(name: "Lait de coco", quantity: 100, unit: "ml")
            ]
        )

        let vegetarianOmelette = Recipe(
            name: "Omelette au fromage",
            category: "Vegetarian",
            ingredients: [
                Ingredient(name: "Œufs entiers", quantity: 3, unit: "pièces"),
                Ingredient(name: "Fromage râpé", quantity: 30, unit: "g")
            ]
        )

        // Vegetarian excludes chicken and seafood
        XCTAssertFalse(filterService.isRecipeDietaryCompliant(chickenSalad, dietaryPreferences: ["vegetarian"]))
        XCTAssertFalse(filterService.isRecipeDietaryCompliant(grilledSalmon, dietaryPreferences: ["vegetarian"]))
        XCTAssertTrue(filterService.isRecipeDietaryCompliant(veganCurry, dietaryPreferences: ["vegetarian"]))
        XCTAssertTrue(filterService.isRecipeDietaryCompliant(vegetarianOmelette, dietaryPreferences: ["vegetarian"]))

        // Vegan excludes eggs and cheese
        XCTAssertFalse(filterService.isRecipeDietaryCompliant(vegetarianOmelette, dietaryPreferences: ["vegan"]))
        XCTAssertTrue(filterService.isRecipeDietaryCompliant(veganCurry, dietaryPreferences: ["vegan"]))

        // Pescatarian excludes land meat but allows fish
        XCTAssertFalse(filterService.isRecipeDietaryCompliant(chickenSalad, dietaryPreferences: ["pescatarian"]))
        XCTAssertTrue(filterService.isRecipeDietaryCompliant(grilledSalmon, dietaryPreferences: ["pescatarian"]))
    }

    func testDislikedIngredientsExclusion() {
        let recipeWithCilantro = Recipe(
            name: "Tacos mexicains",
            ingredients: [
                Ingredient(name: "Bœuf", quantity: 150, unit: "g"),
                Ingredient(name: "Coriandre fraîche", quantity: 5, unit: "g")
            ]
        )

        // Case and diacritics insensitive check
        XCTAssertFalse(filterService.isRecipeFreeFromDisliked(recipeWithCilantro, dislikedIngredients: ["coriandre"]))
        XCTAssertTrue(filterService.isRecipeFreeFromDisliked(recipeWithCilantro, dislikedIngredients: ["céleri"]))
    }

    func testPreparationTimeCompliance() {
        let fastRecipe = Recipe(name: "Express Bowl", preparationTime: 15)
        let slowRecipe = Recipe(name: "Boeuf Bourguignon", preparationTime: 120)

        XCTAssertTrue(filterService.isRecipePrepTimeCompliant(fastRecipe, maxPreparationTime: 30))
        XCTAssertFalse(filterService.isRecipePrepTimeCompliant(slowRecipe, maxPreparationTime: 30))
        XCTAssertTrue(filterService.isRecipePrepTimeCompliant(slowRecipe, maxPreparationTime: nil))
    }

    func testPantryAndCuisineScoringPrioritization() {
        let italianPasta = Recipe(
            name: "Spaghetti Courgettes",
            area: "Italian",
            ingredients: [
                Ingredient(name: "Courgettes", quantity: 200, unit: "g"),
                Ingredient(name: "Pâtes", quantity: 100, unit: "g")
            ]
        )

        let frenchStew = Recipe(
            name: "Pot-au-feu",
            area: "French",
            ingredients: [
                Ingredient(name: "Bœuf", quantity: 200, unit: "g"),
                Ingredient(name: "Carottes", quantity: 100, unit: "g")
            ]
        )

        let preferences = WeeklyPreferences(
            budget: 60,
            dailyCalories: 2000,
            maxPreparationTime: 45,
            preferences: ["Italienne"],
            availableIngredients: ["Courgettes"],
            numberOfPeople: 1
        )

        let italianScore = filterService.scoreRecipe(italianPasta, preferences: preferences)
        let frenchScore = filterService.scoreRecipe(frenchStew, preferences: preferences)

        // Italian recipe matches both cuisine preference and pantry ingredient
        XCTAssertGreaterThan(italianScore, frenchScore)
    }
}
