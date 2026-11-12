import Foundation

public protocol RecipeServiceProtocol: Sendable {
    func searchRecipes(query: String) async throws -> [Recipe]
    func fetchRecipeDetails(id: String) async throws -> Recipe
    func fetchCategories() async throws -> [String]
    func fetchRecipesByCategory(_ category: String) async throws -> [Recipe]
    func fetchRandomRecipe() async throws -> Recipe
}
