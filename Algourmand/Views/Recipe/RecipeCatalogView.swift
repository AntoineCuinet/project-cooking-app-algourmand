import AlgourmandCore
import AlgourmandCoreUI
import SwiftUI

struct RecipeCatalogView: View {
    @StateObject private var viewModel = RecipeCatalogViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchAndFilterBar

                contentArea
            }
            .background(Color.algourmandBackground.ignoresSafeArea())
            .navigationTitle("Catalogue")
            .task {
                await viewModel.loadInitialData()
            }
        }
    }

    // MARK: - Search & Filters
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.algourmandPrimary)

                TextField("Rechercher une recette (ex: Poulet, Pasta...)", text: $viewModel.searchQuery)
                    .foregroundStyle(Color.algourmandText)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.searchQuery) { _, newValue in
                        viewModel.onSearchQueryChanged(newValue)
                    }

                if !viewModel.searchQuery.isEmpty {
                    Button {
                        viewModel.searchQuery = ""
                        viewModel.onSearchQueryChanged("")
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.algourmandText.opacity(0.5))
                    }
                }
            }
            .padding(12)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)

            categoriesFilter
        }
        .padding(.vertical, 10)
    }

    private var categoriesFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.categories, id: \.self) { category in
                    SelectableTag(
                        title: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        Task {
                            await viewModel.selectCategory(category)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Content Area
    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoading && viewModel.recipes.isEmpty {
            Spacer()
            ProgressView("Chargement des recettes...")
                .tint(Color.algourmandPrimary)
            Spacer()
        } else if let error = viewModel.errorMessage, viewModel.recipes.isEmpty {
            errorView(error)
        } else if viewModel.recipes.isEmpty {
            emptyStateView
        } else {
            recipeList
        }
    }

    private var recipeList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.recipes) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        RecipeCardView(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .refreshable {
            await viewModel.reload()
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 44))
                .foregroundStyle(Color.orange)

            Text("Impossible de charger les recettes")
                .font(.headline)
                .foregroundStyle(Color.algourmandText)

            Text(message)
                .font(.caption)
                .foregroundStyle(Color.algourmandText.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Réessayer") {
                Task {
                    await viewModel.reload()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.algourmandPrimary)
            .controlSize(.regular)
            Spacer()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(Color.algourmandText.opacity(0.3))

            Text("Aucune recette trouvée")
                .font(.headline)
                .foregroundStyle(Color.algourmandText)

            Text("Essayez avec un autre ingrédient ou une autre catégorie.")
                .font(.caption)
                .foregroundStyle(Color.algourmandText.opacity(0.6))
            Spacer()
        }
    }
}

#Preview {
    RecipeCatalogView()
}
