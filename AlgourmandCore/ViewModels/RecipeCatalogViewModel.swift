import Combine
import Foundation

@MainActor
public final class RecipeCatalogViewModel: ObservableObject {
    // MARK: - Published State
    @Published public var recipes: [Recipe] = []
    @Published public var categories: [String] = ["Tous"]
    @Published public var selectedCategory: String = "Tous"
    @Published public var searchQuery: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    // MARK: - Dependencies
    private let recipeService: RecipeServiceProtocol
    private var searchTask: Task<Void, Never>?

    // MARK: - Initialization
    public init(recipeService: RecipeServiceProtocol = TheMealDBService()) {
        self.recipeService = recipeService
    }

    // MARK: - Data Loading
    public func loadInitialData() async {
        guard recipes.isEmpty else { return }
        await reload()
    }

    public func reload() async {
        isLoading = true
        errorMessage = nil

        do {
            async let fetchedCategories = recipeService.fetchCategories()
            async let fetchedRecipes = recipeService.searchRecipes(query: "")

            let (cats, recs) = try await (fetchedCategories, fetchedRecipes)
            self.categories = ["Tous"] + cats
            self.recipes = recs
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Filter & Search
    public func selectCategory(_ category: String) async {
        selectedCategory = category
        searchQuery = ""
        isLoading = true
        errorMessage = nil

        do {
            if category == "Tous" {
                self.recipes = try await recipeService.searchRecipes(query: "")
            } else {
                self.recipes = try await recipeService.fetchRecipesByCategory(category)
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    public func onSearchQueryChanged(_ newQuery: String) {
        searchTask?.cancel()
        searchTask = Task {
            guard !Task.isCancelled else { return }
            await performSearch(query: newQuery)
        }
    }

    public func performSearch(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        isLoading = true
        errorMessage = nil

        do {
            if trimmed.isEmpty {
                if selectedCategory == "Tous" {
                    self.recipes = try await recipeService.searchRecipes(query: "")
                } else {
                    self.recipes = try await recipeService.fetchRecipesByCategory(selectedCategory)
                }
            } else {
                self.recipes = try await recipeService.searchRecipes(query: trimmed)
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
