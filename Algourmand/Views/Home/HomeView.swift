import AlgourmandCore
import AlgourmandCoreUI
import SwiftUI
import UIKit

struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel

    @State private var searchText = ""
    @State private var selectedCategory = "Tous"
    @State private var showingLogoutConfirmation = false

    private let categories = ["Tous", "Plat", "Dessert", "Entrée"]

    private let sampleRecipes: [Recipe] = [
        Recipe(
            id: UUID(),
            name: "Tarte Tatin aux Pommes Caramélisées",
            category: "Dessert",
            preparationTime: 45,
            calories: 380,
            proteins: 4.5,
            carbohydrates: 52.0,
            fats: 16.0
        ),
        Recipe(
            id: UUID(),
            name: "Gratin Dauphinois Traditionnel",
            category: "Plat",
            preparationTime: 60,
            calories: 520,
            proteins: 12.0,
            carbohydrates: 45.0,
            fats: 28.0
        ),
        Recipe(
            id: UUID(),
            name: "Velouté de Potimarron & Châtaignes",
            category: "Entrée",
            preparationTime: 25,
            calories: 220,
            proteins: 5.0,
            carbohydrates: 28.0,
            fats: 8.0
        ),
        Recipe(
            id: UUID(),
            name: "Risotto Crémeux aux Champignons",
            category: "Plat",
            preparationTime: 35,
            calories: 460,
            proteins: 11.0,
            carbohydrates: 62.0,
            fats: 14.0
        )
    ]

    private var filteredRecipes: [Recipe] {
        sampleRecipes.filter { recipe in
            let matchesCategory = (selectedCategory == "Tous" || recipe.category == selectedCategory)
            let matchesSearch = searchText.isEmpty || recipe.name.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    welcomeHeader

                    searchBar

                    categoryFilter

                    recipesSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Accueil")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    profileMenu
                }
            }
            .confirmationDialog(
                "Voulez-vous vraiment vous déconnecter ?",
                isPresented: $showingLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Se déconnecter", role: .destructive) {
                    Task {
                        await viewModel.logout()
                    }
                }
                Button("Annuler", role: .cancel) {}
            }
        }
    }

    // MARK: - Welcome Header
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let user = viewModel.currentUser {
                Text("Bonjour, \(user.username) !")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            } else {
                Text("Bienvenue sur Algourmand !")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }

            Text("Prêt à cuisiner de bonnes recettes aujourd'hui ?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Rechercher une recette...", text: $searchText)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    categoryChip(for: category)
                }
            }
        }
    }

    private func categoryChip(for category: String) -> some View {
        let isSelected = (selectedCategory == category)

        return Button {
            selectedCategory = category
        } label: {
            Text(category)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color(uiColor: .secondarySystemGroupedBackground))
                .foregroundStyle(isSelected ? Color.white : Color(uiColor: .label))
                .clipShape(Capsule())
        }
        .font(.subheadline)
    }

    // MARK: - Recipes Section
    private var recipesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recettes du moment")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Text("\(filteredRecipes.count) recette(s)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if filteredRecipes.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "fork.knife")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("Aucune recette trouvée")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredRecipes) { recipe in
                        RecipeCardView(recipe: recipe)
                    }
                }
            }
        }
    }

    // MARK: - Profile Menu
    private var profileMenu: some View {
        Menu {
            if let user = viewModel.currentUser {
                Section(user.email) {
                    Label("ID: \(user.id)", systemImage: "person.badge.key")
                }
            }

            Button(role: .destructive) {
                showingLogoutConfirmation = true
            } label: {
                Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.orange)
            }
        }
    }
}

#Preview {
    HomeView(viewModel: AuthViewModel())
}
