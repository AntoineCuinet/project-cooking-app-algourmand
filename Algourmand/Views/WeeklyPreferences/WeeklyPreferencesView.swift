import AlgourmandCore
import AlgourmandCoreUI
import SwiftUI

struct WeeklyPreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = WeeklyPreferencesViewModel()
    let userId: UUID
    let onSaved: (() -> Void)?

    init(userId: UUID, onSaved: (() -> Void)? = nil) {
        self.userId = userId
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerCard
                    prepTimeSection
                    cuisinesSection
                    householdSection
                    availableIngredientsSection
                    saveButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color.algourmandBackground.ignoresSafeArea())
            .navigationTitle("Préférences semaine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundStyle(Color.algourmandText)
                }
            }
            .onAppear {
                viewModel.loadExistingPreferences(for: userId)
            }
        }
    }

    // MARK: - Header
    private var headerCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.algourmandPrimary.opacity(0.12))
                    .frame(width: 56, height: 56)

                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Color.algourmandPrimary)
            }

            VStack(spacing: 4) {
                Text("Vos envies pour cette semaine")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.algourmandText)

                Text("Ces critères guident l'algorithme pour composer votre menu hebdomadaire sur-mesure.")
                    .font(.caption)
                    .foregroundStyle(Color.algourmandText.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Preparation Time Section
    private var prepTimeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Temps de préparation max")
                        .font(.headline)
                        .foregroundStyle(Color.algourmandText)

                    Spacer()

                    Text(viewModel.hasNoTimeLimit ? "Sans limite" : "\(viewModel.maxPreparationTime) min max")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.algourmandPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.algourmandPrimary.opacity(0.12))
                        .clipShape(Capsule())
                }

                Text("Choisissez le temps que vous souhaitez consacrer aux repas les soirs de semaine.")
                    .font(.caption)
                    .foregroundStyle(Color.algourmandText.opacity(0.7))
            }

            HStack(spacing: 8) {
                ForEach(viewModel.prepTimePresets, id: \.self) { minutes in
                    let isSelected = !viewModel.hasNoTimeLimit && viewModel.maxPreparationTime == minutes
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.hasNoTimeLimit = false
                            viewModel.maxPreparationTime = minutes
                        }
                    } label: {
                        Text("\(minutes)m")
                            .font(.caption)
                            .fontWeight(isSelected ? .bold : .medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                isSelected ?
                                Color.algourmandPrimary :
                                Color(uiColor: .tertiarySystemGroupedBackground)
                            )
                            .foregroundStyle(isSelected ? Color.white : Color.algourmandText)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.hasNoTimeLimit.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.hasNoTimeLimit ? "checkmark.square.fill" : "square")
                        .foregroundStyle(
                            viewModel.hasNoTimeLimit ? Color.algourmandPrimary : Color.algourmandText.opacity(0.4)
                        )
                    Text("Pas de limite de temps particulière cette semaine")
                        .font(.caption)
                        .foregroundStyle(Color.algourmandText.opacity(0.85))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Cuisines Section
    private var cuisinesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Préférences culinaires")
                    .font(.headline)
                    .foregroundStyle(Color.algourmandText)

                Text("Quels styles de cuisine vous font envie ces prochains jours ? (choix multiple)")
                    .font(.caption)
                    .foregroundStyle(Color.algourmandText.opacity(0.7))
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 8)], spacing: 8) {
                ForEach(viewModel.availableCuisines, id: \.self) { cuisine in
                    SelectableTag(
                        title: cuisine,
                        isSelected: viewModel.isCuisineSelected(cuisine)
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleCuisine(cuisine)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Household Logistics
    private var householdSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Organisation du foyer")
                .font(.headline)
                .foregroundStyle(Color.algourmandText)

            CounterCard(
                title: "Nombre de personnes",
                subtitle: "Portions calculées par repas",
                valueText: "\(viewModel.numberOfPeople)",
                systemImage: "person.2.fill",
                canDecrement: viewModel.numberOfPeople > 1,
                canIncrement: viewModel.numberOfPeople < 12,
                onDecrement: { viewModel.numberOfPeople -= 1 },
                onIncrement: { viewModel.numberOfPeople += 1 }
            )

            CounterCard(
                title: "Budget estimé de la semaine",
                subtitle: "Objectif de courses pour vos recettes",
                valueText: "\(Int(viewModel.budget)) €",
                systemImage: "creditcard.fill",
                canDecrement: viewModel.budget > 20,
                canIncrement: viewModel.budget < 400,
                onDecrement: { viewModel.budget = max(20, viewModel.budget - 10) },
                onIncrement: { viewModel.budget += 10 }
            )
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Available Ingredients (Anti-waste)
    private var availableIngredientsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dans vos placards & frigo (anti-gaspi)")
                    .font(.headline)
                    .foregroundStyle(Color.algourmandText)

                Text("Ingrédients déjà en votre possession à intégrer en priorité dans vos repas.")
                    .font(.caption)
                    .foregroundStyle(Color.algourmandText.opacity(0.7))
            }

            HStack(spacing: 8) {
                TextField("Ex: Pâtes, Carottes, Riz...", text: $viewModel.ingredientInput)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onSubmit {
                        viewModel.addIngredient(viewModel.ingredientInput)
                    }

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.addIngredient(viewModel.ingredientInput)
                    }
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.algourmandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(viewModel.ingredientInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if !viewModel.availableIngredients.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], spacing: 8) {
                    ForEach(viewModel.availableIngredients, id: \.self) { ingredient in
                        HStack(spacing: 6) {
                            Text(ingredient)
                                .font(.caption)
                                .foregroundStyle(Color.algourmandText)

                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.removeIngredient(ingredient)
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.algourmandText.opacity(0.5))
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.algourmandPrimary.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Save Action
    private var saveButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                if viewModel.savePreferences(for: userId) {
                    onSaved?()
                    dismiss()
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                Text("Valider mes préférences de la semaine")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 24)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.algourmandPrimary)
        .controlSize(.large)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.top, 8)
    }
}

#Preview {
    WeeklyPreferencesView(userId: UUID())
}
