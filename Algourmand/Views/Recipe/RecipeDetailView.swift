import AlgourmandCore
import AlgourmandCoreUI
import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                recipeImage

                VStack(alignment: .leading, spacing: 22) {
                    headerSection
                    macrosSection
                    ingredientsSection
                    instructionsSection

                    if let youtube = recipe.youtubeURL, let url = URL(string: youtube) {
                        youtubeButton(url: url)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .background(Color.algourmandBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Recipe Image
    @ViewBuilder
    private var recipeImage: some View {
        if let imageString = recipe.image, let url = URL(string: imageString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.algourmandPrimary.opacity(0.1))
                        .frame(height: 260)
                        .overlay {
                            ProgressView()
                        }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 260)
                        .clipped()
                case .failure:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
        } else {
            placeholderImage
        }
    }

    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.algourmandPrimary.opacity(0.08))
            .frame(height: 220)
            .overlay {
                Image(systemName: "fork.knife")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.algourmandPrimary.opacity(0.3))
            }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(recipe.category.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.algourmandSecondary.opacity(0.15))
                    .foregroundStyle(Color.algourmandSecondary)
                    .clipShape(Capsule())

                if let area = recipe.area, !area.isEmpty {
                    Text(area)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.algourmandPrimary.opacity(0.12))
                        .foregroundStyle(Color.algourmandPrimary)
                        .clipShape(Capsule())
                }

                Spacer()

                if recipe.preparationTime > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text("\(recipe.preparationTime) min")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.algourmandText.opacity(0.7))
                }
            }

            Text(recipe.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.algourmandText)

            if !recipe.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(recipe.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption2)
                            .foregroundStyle(Color.algourmandText.opacity(0.55))
                    }
                }
            }
        }
    }

    // MARK: - Nutritional Macros
    private var macrosSection: some View {
        HStack(spacing: 10) {
            macroTile(label: "Calories", value: "\(Int(recipe.calories))", unit: "kcal", color: .orange)
            macroTile(label: "Protéines", value: "\(Int(recipe.proteins))", unit: "g", color: .red)
            macroTile(label: "Glucides", value: "\(Int(recipe.carbohydrates))", unit: "g", color: .blue)
            macroTile(label: "Lipides", value: "\(Int(recipe.fats))", unit: "g", color: .yellow)
        }
    }

    private func macroTile(label: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.algourmandText.opacity(0.65))

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.algourmandText)
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(Color.algourmandText.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Ingredients Section
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ingrédients")
                    .font(.headline)
                    .foregroundStyle(Color.algourmandText)

                Spacer()

                Text("\(recipe.ingredients.count) ingrédients")
                    .font(.caption)
                    .foregroundStyle(Color.algourmandText.opacity(0.6))
            }

            VStack(spacing: 8) {
                ForEach(recipe.ingredients) { ingredient in
                    HStack {
                        Circle()
                            .fill(Color.algourmandPrimary)
                            .frame(width: 6, height: 6)

                        Text(ingredient.name)
                            .font(.subheadline)
                            .foregroundStyle(Color.algourmandText)

                        Spacer()

                        Text(formatQuantity(ingredient.quantity, unit: ingredient.unit))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.algourmandText.opacity(0.75))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    // MARK: - Instructions Section
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Préparation")
                .font(.headline)
                .foregroundStyle(Color.algourmandText)

            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                            .frame(width: 24, height: 24)
                            .background(Color.algourmandPrimary)
                            .clipShape(Circle())

                        Text(step)
                            .font(.subheadline)
                            .foregroundStyle(Color.algourmandText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - YouTube Button
    private func youtubeButton(url: URL) -> some View {
        Link(destination: url) {
            HStack(spacing: 8) {
                Image(systemName: "play.rectangle.fill")
                    .foregroundStyle(.red)
                Text("Regarder le tutoriel vidéo sur YouTube")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.algourmandText)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private func formatQuantity(_ quantity: Double, unit: String) -> String {
        let quantityString = (quantity.truncatingRemainder(dividingBy: 1) == 0) ?
            "\(Int(quantity))" :
            String(format: "%.1f", quantity)

        if unit == "portion" {
            return quantityString
        }
        return "\(quantityString) \(unit)"
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: MockRecipeService.sampleRecipes[0])
    }
}
