import AlgourmandCore
import AlgourmandCoreUI
import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel

    @State private var searchText = ""
    @State private var selectedCategory = "Tous"
    @State private var showingLogoutConfirmation = false
    @State private var showingWeeklyPreferences = false
    @State private var savedWeeklyPreferences: WeeklyPreferences?

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

                    weeklyPreferencesBanner

                    searchBar

                    categoryFilter

                    recipesSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color.algourmandBackground.ignoresSafeArea())
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
            .sheet(isPresented: $showingWeeklyPreferences) {
                if let user = viewModel.currentUser {
                    WeeklyPreferencesView(userId: user.id) {
                        refreshWeeklyPreferences()
                    }
                }
            }
            .onAppear {
                refreshWeeklyPreferences()
            }
            .onChange(of: viewModel.currentUser?.id) {
                refreshWeeklyPreferences()
            }
        }
    }

    private func refreshWeeklyPreferences() {
        if let user = viewModel.currentUser {
            savedWeeklyPreferences = LocalWeeklyPreferencesStorage.shared.loadPreferences(for: user.id)
        } else {
            savedWeeklyPreferences = nil
        }
    }

    // MARK: - Weekly Preferences Banner
    @ViewBuilder
    private var weeklyPreferencesBanner: some View {
        if let preferences = savedWeeklyPreferences {
            configuredPreferencesCard(preferences)
        } else {
            pendingPreferencesReminderCard
        }
    }

    // MARK: - Reminder Card
    private var pendingPreferencesReminderCard: some View {
        Button {
            showingWeeklyPreferences = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.14))
                        .frame(width: 44, height: 44)

                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.orange)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Préférences de la semaine")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.algourmandText)

                        Text("À configurer")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                    }

                    Text("Renseignez vos critères pour générer vos repas de la semaine.")
                        .font(.caption)
                        .foregroundStyle(Color.algourmandText.opacity(0.7))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.algourmandText.opacity(0.4))
            }
            .padding(14)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.orange.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: Color.orange.opacity(0.06), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Configured Summary Card
    private func configuredPreferencesCard(_ preferences: WeeklyPreferences) -> some View {
        Button {
            showingWeeklyPreferences = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.algourmandSuccess.opacity(0.15))
                            .frame(width: 40, height: 40)

                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.algourmandSuccess)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("Menu de la semaine configuré")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.algourmandText)

                            Text("Actif")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.algourmandSuccess.opacity(0.15))
                                .foregroundStyle(Color.algourmandSuccess)
                                .clipShape(Capsule())
                        }

                        Text("Vos critères guident les suggestions de repas.")
                            .font(.caption2)
                            .foregroundStyle(Color.algourmandText.opacity(0.7))
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Text("Modifier")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .foregroundStyle(Color.algourmandPrimary)
                }

                HStack(spacing: 8) {
                    summaryChip(
                        icon: "clock.fill",
                        text: preferences.maxPreparationTime.map { "\($0) min" } ?? "Sans limite"
                    )

                    summaryChip(
                        icon: "person.2.fill",
                        text: "\(preferences.numberOfPeople) pers."
                    )

                    summaryChip(
                        icon: "creditcard.fill",
                        text: "\(Int(preferences.budget)) €"
                    )
                }

                if !preferences.preferences.isEmpty {
                    Text(preferences.preferences.joined(separator: " • "))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.algourmandPrimary)
                        .lineLimit(1)
                }
            }
            .padding(14)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.algourmandPrimary.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.algourmandPrimary.opacity(0.06), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    private func summaryChip(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundStyle(Color.algourmandText.opacity(0.85))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.algourmandBackground)
        .clipShape(Capsule())
    }

    // MARK: - Welcome Header
    private var welcomeHeader: some View {
        HStack(spacing: 14) {
            Image.algourmandLogo
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .shadow(color: Color.algourmandPrimary.opacity(0.15), radius: 6, x: 0, y: 3)

            VStack(alignment: .leading, spacing: 4) {
                if let user = viewModel.currentUser {
                    Text("Bonjour, \(user.username) !")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.algourmandText)
                } else {
                    Text("Bienvenue sur Algourmand !")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.algourmandText)
                }

                Text("Prêt à cuisiner de bonnes recettes aujourd'hui ?")
                    .font(.subheadline)
                    .foregroundStyle(Color.algourmandText.opacity(0.7))
            }

            Spacer()
        }
        .padding(.top, 4)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.algourmandPrimary)

            TextField("Rechercher une recette...", text: $searchText)
                .foregroundStyle(Color.algourmandText)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.algourmandText.opacity(0.5))
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
                .background(isSelected ? Color.algourmandPrimary : Color(uiColor: .secondarySystemGroupedBackground))
                .foregroundStyle(isSelected ? Color.white : Color.algourmandText)
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
                    .foregroundStyle(Color.algourmandText)

                Spacer()

                Text("\(filteredRecipes.count) recette(s)")
                    .font(.caption)
                    .foregroundStyle(Color.algourmandText.opacity(0.6))
            }

            if filteredRecipes.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "fork.knife")
                        .font(.largeTitle)
                        .foregroundStyle(Color.algourmandText.opacity(0.4))
                    Text("Aucune recette trouvée")
                        .font(.subheadline)
                        .foregroundStyle(Color.algourmandText.opacity(0.6))
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
                    .fill(Color.algourmandPrimary.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.algourmandPrimary)
            }
        }
    }
}

#Preview {
    HomeView(viewModel: AuthViewModel())
}
