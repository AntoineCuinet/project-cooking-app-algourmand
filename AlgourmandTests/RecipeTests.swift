@testable import AlgourmandCore
import XCTest

final class RecipeTests: XCTestCase {
    func testRecipeInitialization() {
        let recipeId = UUID()
        let ingredientId = UUID()
        let ingredient = Ingredient(
            id: ingredientId,
            name: "Pommes de terre",
            quantity: 1000,
            unit: "g"
        )

        let recipe = Recipe(
            id: recipeId,
            name: "Gratin Dauphinois",
            image: "https://example.com/gratin.jpg",
            category: "Plat",
            ingredients: [ingredient],
            instructions: ["Éplucher les pommes de terre", "Cuire au four"],
            preparationTime: 60,
            calories: 520,
            proteins: 12,
            carbohydrates: 45,
            fats: 28
        )

        XCTAssertEqual(recipe.id, recipeId)
        XCTAssertEqual(recipe.name, "Gratin Dauphinois")
        XCTAssertEqual(recipe.category, "Plat")
        XCTAssertEqual(recipe.preparationTime, 60)
        XCTAssertEqual(recipe.calories, 520)
        XCTAssertEqual(recipe.ingredients.count, 1)
        XCTAssertEqual(recipe.ingredients.first?.name, "Pommes de terre")
    }

    func testTheMealDBDecodingAndDomainMapping() throws {
        let rawJSON = """
        {
            "idMeal": "52772",
            "strMeal": "Teriyaki Chicken Casserole",
            "strCategory": "Chicken",
            "strArea": "Japanese",
            "strInstructions": "STEP 1: Preheat oven to 350° F.\\r\\nSTEP 2: Bake for 30 minutes.\\r\\n",
            "strMealThumb": "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg",
            "strTags": "Meat,Casserole",
            "strYoutube": "https://www.youtube.com/watch?v=4aZr5hZXP_s",
            "strIngredient1": "Soy Sauce",
            "strMeasure1": "3/4 cup",
            "strIngredient2": "Water",
            "strMeasure2": "1/2 cup",
            "strIngredient3": "Chicken Breast",
            "strMeasure3": "200g",
            "strIngredient4": "",
            "strMeasure4": "",
            "strIngredient5": null,
            "strMeasure5": null
        }
        """

        let data = Data(rawJSON.utf8)
        let dto = try JSONDecoder().decode(TheMealDBMealDTO.self, from: data)

        XCTAssertEqual(dto.idMeal, "52772")
        XCTAssertEqual(dto.strMeal, "Teriyaki Chicken Casserole")
        XCTAssertEqual(dto.ingredientsWithMeasures.count, 3)
        XCTAssertEqual(dto.ingredientsWithMeasures[0].ingredient, "Soy Sauce")
        XCTAssertEqual(dto.ingredientsWithMeasures[0].measure, "3/4 cup")

        let recipe = dto.toDomain()
        XCTAssertEqual(recipe.externalId, "52772")
        XCTAssertEqual(recipe.name, "Teriyaki Chicken Casserole")
        XCTAssertEqual(recipe.category, "Chicken")
        XCTAssertEqual(recipe.area, "Japanese")
        XCTAssertEqual(recipe.tags, ["Meat", "Casserole"])
        XCTAssertEqual(recipe.ingredients.count, 3)
        XCTAssertEqual(recipe.ingredients[0].name, "Soy Sauce")
        XCTAssertEqual(recipe.ingredients[0].quantity, 0.75)
        XCTAssertEqual(recipe.ingredients[0].unit, "cup")
        XCTAssertEqual(recipe.instructions.count, 2)
        XCTAssertEqual(recipe.instructions[0], "Preheat oven to 350° F.")
        XCTAssertEqual(recipe.instructions[1], "Bake for 30 minutes.")
        XCTAssertGreaterThan(recipe.preparationTime, 0)
        XCTAssertGreaterThan(recipe.calories, 0)
    }

    func testMeasureParsingAndHelpers() {
        let (q1, u1) = TheMealDBMealDTO.parseMeasure("3/4 cup")
        XCTAssertEqual(q1, 0.75)
        XCTAssertEqual(u1, "cup")

        let (q2, u2) = TheMealDBMealDTO.parseMeasure("150 g")
        XCTAssertEqual(q2, 150.0)
        XCTAssertEqual(u2, "g")

        let (q3, u3) = TheMealDBMealDTO.parseMeasure("To taste")
        XCTAssertEqual(q3, 1.0)
        XCTAssertEqual(u3, "To taste")

        // Deterministic UUIDs must be stable across multiple calls
        let uuid1 = TheMealDBMealDTO.makeDeterministicUUID(from: "52772")
        let uuid2 = TheMealDBMealDTO.makeDeterministicUUID(from: "52772")
        XCTAssertEqual(uuid1, uuid2)
    }

    @MainActor
    func testRecipeCatalogViewModelDefaultState() {
        let viewModel = RecipeCatalogViewModel()
        XCTAssertEqual(viewModel.selectedCategory, "Tous")
        XCTAssertEqual(viewModel.categories, ["Tous"])
        XCTAssertTrue(viewModel.recipes.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
}
