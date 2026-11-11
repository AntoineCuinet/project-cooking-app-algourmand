import AlgourmandCore
import AlgourmandCoreUI
import SwiftUI

struct DislikedIngredientsStepView: View {
    @ObservedObject var viewModel: ProfileSetupViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            headerSection
            inputFieldSection
            selectedTagsSection
            popularSuggestionsSection
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Aliments & ingrédients détestés")
                .font(.headline)
                .foregroundStyle(Color.algourmandText)

            Text("Ajoutez les aliments que vous n'aimez pas pour qu'ils soient évités dans vos repas.")
                .font(.caption)
                .foregroundStyle(Color.algourmandText.opacity(0.7))
        }
    }

    private var inputFieldSection: some View {
        HStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.algourmandText.opacity(0.4))

                TextField("Ex: Coriandre, Céleri...", text: $viewModel.dislikedIngredientInput)
                    .autocorrectionDisabled()
                    .onSubmit {
                        viewModel.addDislikedIngredient(viewModel.dislikedIngredientInput)
                    }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(uiColor: .tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.addDislikedIngredient(viewModel.dislikedIngredientInput)
                }
            } label: {
                Image(systemName: "plus")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.algourmandPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.dislikedIngredientInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private var selectedTagsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ingrédients exclus (\(viewModel.dislikedIngredients.count))")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.algourmandText.opacity(0.8))

            if viewModel.dislikedIngredients.isEmpty {
                Text("Aucun ingrédient exclu pour le moment (optionnel).")
                    .font(.caption)
                    .italic()
                    .foregroundStyle(Color.algourmandText.opacity(0.5))
                    .padding(.vertical, 6)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 8)], spacing: 8) {
                    ForEach(viewModel.dislikedIngredients, id: \.self) { ingredient in
                        HStack(spacing: 6) {
                            Text(ingredient)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.algourmandText)
                                .lineLimit(1)

                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.removeDislikedIngredient(ingredient)
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.algourmandText.opacity(0.5))
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.algourmandPrimary.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var popularSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Suggestions populaires")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.algourmandText.opacity(0.8))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], spacing: 8) {
                ForEach(viewModel.popularDislikedSuggestions, id: \.self) { suggestion in
                    let isAlreadyAdded = viewModel.dislikedIngredients.contains {
                        $0.caseInsensitiveCompare(suggestion) == .orderedSame
                    }

                    if !isAlreadyAdded {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.addDislikedIngredient(suggestion)
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.caption2)
                                Text(suggestion)
                                    .font(.caption)
                            }
                            .foregroundStyle(Color.algourmandText.opacity(0.8))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(uiColor: .tertiarySystemGroupedBackground))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview {
    DislikedIngredientsStepView(viewModel: ProfileSetupViewModel())
        .padding()
        .background(Color.algourmandBackground)
}
