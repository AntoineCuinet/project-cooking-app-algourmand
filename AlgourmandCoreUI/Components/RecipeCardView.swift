import AlgourmandCore
import SwiftUI

public struct RecipeCardView: View {
    public let recipe: Recipe

    public init(recipe: Recipe) {
        self.recipe = recipe
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            recipeImageHeader

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Text(recipe.category.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.algourmandSecondary)

                    if let area = recipe.area, !area.isEmpty {
                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(Color.algourmandText.opacity(0.4))
                        Text(area)
                            .font(.caption2)
                            .foregroundStyle(Color.algourmandText.opacity(0.7))
                    }

                    Spacer()

                    if recipe.preparationTime > 0 {
                        Label("\(recipe.preparationTime) min", systemImage: "clock")
                            .font(.caption2)
                            .foregroundStyle(Color.algourmandText.opacity(0.7))
                    }
                }

                Text(recipe.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.algourmandText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if recipe.calories > 0 {
                    HStack(spacing: 8) {
                        Label("\(Int(recipe.calories)) kcal", systemImage: "flame.fill")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.algourmandPrimary)

                        if recipe.proteins > 0 {
                            Text("• \(Int(recipe.proteins))g prot.")
                                .font(.caption2)
                                .foregroundStyle(Color.algourmandText.opacity(0.6))
                        }
                    }
                }
            }
            .padding(14)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.algourmandPrimary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.algourmandPrimary.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    @ViewBuilder
    private var recipeImageHeader: some View {
        if let imageString = recipe.image, let url = URL(string: imageString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.algourmandBackground)
                        .frame(height: 160)
                        .overlay {
                            ProgressView()
                        }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipped()
                case .failure:
                    imagePlaceholder
                @unknown default:
                    imagePlaceholder
                }
            }
        } else {
            imagePlaceholder
        }
    }

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(Color.algourmandPrimary.opacity(0.08))
            .frame(height: 140)
            .overlay {
                Image(systemName: "fork.knife")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.algourmandPrimary.opacity(0.4))
            }
    }
}
