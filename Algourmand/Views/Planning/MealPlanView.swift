import AlgourmandCore
import AlgourmandCoreUI
import SwiftUI

public struct MealPlanView: View {
    @ObservedObject var viewModel: MealPlanViewModel
    public let user: UserDTO
    public let profile: UserProfile
    public let preferences: WeeklyPreferences?
    public let needs: NutritionNeeds?

    @State private var showingRegenerateConfirmation = false

    public init(
        viewModel: MealPlanViewModel,
        user: UserDTO,
        profile: UserProfile,
        preferences: WeeklyPreferences?,
        needs: NutritionNeeds? = nil
    ) {
        self.viewModel = viewModel
        self.user = user
        self.profile = profile
        self.preferences = preferences
        self.needs = needs
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.currentPlan == nil {
                    emptyPlanView
                } else {
                    dayPickerSection

                    dailyNutritionSummaryCard

                    mealsForDaySection
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.algourmandBackground.ignoresSafeArea())
        .navigationTitle("Mon Planning")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.currentPlan != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingRegenerateConfirmation = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Régénérer")
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.algourmandPrimary)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .confirmationDialog(
            "Régénérer le planning ?",
            isPresented: $showingRegenerateConfirmation,
            titleVisibility: .visible
        ) {
            Button("Régénérer la semaine", role: .destructive) {
                Task {
                    await viewModel.generatePlan(
                        for: user.id,
                        profile: profile,
                        preferences: preferences
                    )
                }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Les repas que vous avez verrouillés avec le cadenas seront conservés.")
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.15).ignoresSafeArea()
                    ProgressView("Création de votre planning...")
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }

    // MARK: - Day Picker
    private var dayPickerSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.daysOfWeek, id: \.self) { date in
                    dayPickerPill(for: date)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func dayPickerPill(for date: Date) -> some View {
        let calendar = Calendar.current
        let isSelected = calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
        let isToday = calendar.isDateInToday(date)

        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "fr_FR")
        weekdayFormatter.dateFormat = "EEE"

        let dayNumber = calendar.component(.day, from: date)
        let weekdayTitle = weekdayFormatter.string(from: date).capitalized

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedDate = date
            }
        } label: {
            VStack(spacing: 6) {
                Text(weekdayTitle)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(isSelected ? Color.white.opacity(0.9) : Color.algourmandText.opacity(0.6))

                Text("\(dayNumber)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(isSelected ? Color.white : Color.algourmandText)

                Circle()
                    .fill(isSelected ? Color.white : (isToday ? Color.algourmandPrimary : Color.clear))
                    .frame(width: 5, height: 5)
            }
            .frame(width: 54, height: 74)
            .background(isSelected ? Color.algourmandPrimary : Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: isSelected ? Color.algourmandPrimary.opacity(0.3) : Color.black.opacity(0.03), radius: 5, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Daily Nutrition Target Card
    private var dailyNutritionSummaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Apports prévus sur la journée", systemImage: "flame.fill")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.algourmandPrimary)

                Spacer()

                Text("\(Int(viewModel.caloriesForSelectedDate)) kcal")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.algourmandText)
            }

            if let target = needs?.targetCalories, target > 0 {
                let ratio = min(viewModel.caloriesForSelectedDate / target, 1.0)
                ProgressView(value: ratio)
                    .tint(Color.algourmandPrimary)
            }

            HStack(spacing: 8) {
                macroPill(title: "Protéines", grams: viewModel.proteinsForSelectedDate, color: .orange)
                macroPill(title: "Lipides", grams: viewModel.fatsForSelectedDate, color: .yellow)
                macroPill(title: "Glucides", grams: viewModel.carbsForSelectedDate, color: .teal)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func macroPill(title: String, grams: Double, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text("\(title): \(Int(grams))g")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.algourmandText.opacity(0.8))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(Capsule())
    }

    // MARK: - Meals of Selected Day
    private var mealsForDaySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            let meals = viewModel.mealsForSelectedDate
            if meals.isEmpty {
                Text("Aucun repas planifié pour ce jour.")
                    .font(.subheadline)
                    .foregroundStyle(Color.algourmandText.opacity(0.6))
                    .padding(.vertical, 20)
            } else {
                ForEach(meals) { meal in
                    mealSlotCard(meal: meal)
                }
            }
        }
    }

    private func mealSlotCard(meal: PlannedMeal) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Slot + Lock / Swap Actions
            HStack(alignment: .center) {
                Label(meal.mealType.displayName, systemImage: meal.mealType.systemIcon)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.algourmandText)

                Spacer()

                // Swap Button
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.regenerateMeal(
                            mealId: meal.id,
                            for: user.id,
                            profile: profile,
                            preferences: preferences
                        )
                    }
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .foregroundStyle(Color.algourmandText.opacity(0.7))
                        .padding(6)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                // Lock Toggle Button
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.toggleMealLock(mealId: meal.id, for: user.id)
                    }
                } label: {
                    Image(systemName: meal.isLocked ? "lock.fill" : "lock.open")
                        .font(.caption)
                        .foregroundStyle(meal.isLocked ? .orange : Color.algourmandText.opacity(0.7))
                        .padding(6)
                        .background((meal.isLocked ? Color.orange : Color.secondary).opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            // NavigationLink to RecipeDetailView
            if let recipe = meal.recipe {
                NavigationLink {
                    RecipeDetailView(recipe: recipe)
                } label: {
                    recipeRowContent(recipe: recipe)
                }
                .buttonStyle(.plain)
            } else {
                Text("Recette non disponible")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
    }

    private func recipeRowContent(recipe: Recipe) -> some View {
        HStack(spacing: 14) {
            // Recipe Image
            if let img = recipe.image, let url = URL(string: img) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }

            // Recipe Metadata
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.name)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundStyle(Color.algourmandText)

                HStack(spacing: 10) {
                    Label("\(recipe.preparationTime) min", systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(Color.algourmandText.opacity(0.7))

                    Label("\(Int(recipe.calories)) kcal", systemImage: "flame.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.algourmandPrimary)

                    if recipe.proteins > 0 {
                        Text("• \(Int(recipe.proteins))g prot.")
                            .font(.caption2)
                            .foregroundStyle(Color.orange)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.algourmandText.opacity(0.3))
        }
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.algourmandPrimary.opacity(0.1))
            .frame(width: 80, height: 80)
            .overlay {
                Image(systemName: "fork.knife")
                    .foregroundStyle(Color.algourmandPrimary.opacity(0.6))
            }
    }

    // MARK: - Empty Plan State
    private var emptyPlanView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(Color.algourmandPrimary)
                .padding(.top, 40)

            Text("Aucun planning généré")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.algourmandText)

            Text("Générez automatiquement 14 repas personnalisés selon vos préférences, temps de préparation et objectifs nutritionnels.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.algourmandText.opacity(0.7))
                .padding(.horizontal, 20)

            Button {
                Task {
                    await viewModel.generatePlan(
                        for: user.id,
                        profile: profile,
                        preferences: preferences
                    )
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                    Text("Générer mon planning")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.algourmandPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
