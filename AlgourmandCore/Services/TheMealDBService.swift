import Foundation

public enum RecipeError: LocalizedError, Sendable {
    case notFound
    case invalidResponse
    case networkError(String)

    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "Aucune recette trouvée."
        case .invalidResponse:
            return "Réponse invalide du serveur de recettes."
        case .networkError(let message):
            return "Erreur réseau : \(message)"
        }
    }
}

public final class TheMealDBService: RecipeServiceProtocol, @unchecked Sendable {
    public let baseURL: URL
    private let session: URLSession

    public init(
        baseURL: URL = URL(string: "https://www.themealdb.com/api/json/v1/1")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    public func searchRecipes(query: String) async throws -> [Recipe] {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("search.php"),
            resolvingAgainstBaseURL: true
        )
        components?.queryItems = [URLQueryItem(name: "s", value: query)]

        guard let url = components?.url else {
            throw RecipeError.invalidResponse
        }

        let (data, response) = try await session.data(from: url)
        try validateHTTP(response)

        let decoded = try JSONDecoder().decode(TheMealDBResponseDTO.self, from: data)
        guard let meals = decoded.meals else {
            return []
        }
        return meals.map { $0.toDomain() }
    }

    public func fetchRecipeDetails(id: String) async throws -> Recipe {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("lookup.php"),
            resolvingAgainstBaseURL: true
        )
        components?.queryItems = [URLQueryItem(name: "i", value: id)]

        guard let url = components?.url else {
            throw RecipeError.invalidResponse
        }

        let (data, response) = try await session.data(from: url)
        try validateHTTP(response)

        let decoded = try JSONDecoder().decode(TheMealDBResponseDTO.self, from: data)
        guard let first = decoded.meals?.first else {
            throw RecipeError.notFound
        }
        return first.toDomain()
    }

    public func fetchCategories() async throws -> [String] {
        let url = baseURL.appendingPathComponent("categories.php")
        let (data, response) = try await session.data(from: url)
        try validateHTTP(response)

        let decoded = try JSONDecoder().decode(TheMealDBCategoriesResponseDTO.self, from: data)
        guard let categories = decoded.categories else {
            return []
        }
        return categories.map { $0.strCategory }
    }

    public func fetchRecipesByCategory(_ category: String) async throws -> [Recipe] {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("filter.php"),
            resolvingAgainstBaseURL: true
        )
        components?.queryItems = [URLQueryItem(name: "c", value: category)]

        guard let url = components?.url else {
            throw RecipeError.invalidResponse
        }

        let (data, response) = try await session.data(from: url)
        try validateHTTP(response)

        let decoded = try JSONDecoder().decode(TheMealDBResponseDTO.self, from: data)
        guard let meals = decoded.meals else {
            return []
        }

        return meals.map { $0.toDomain() }
    }

    public func fetchRandomRecipe() async throws -> Recipe {
        let url = baseURL.appendingPathComponent("random.php")
        let (data, response) = try await session.data(from: url)
        try validateHTTP(response)

        let decoded = try JSONDecoder().decode(TheMealDBResponseDTO.self, from: data)
        guard let first = decoded.meals?.first else {
            throw RecipeError.notFound
        }
        return first.toDomain()
    }

    private func validateHTTP(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw RecipeError.invalidResponse
        }
    }
}
