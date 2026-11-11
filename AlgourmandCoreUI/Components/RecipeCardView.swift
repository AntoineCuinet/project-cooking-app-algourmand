import AlgourmandCore
import SwiftUI

public struct RecipeCardView: View {
    public let recipe: Recipe

    public init(recipe: Recipe) {
        self.recipe = recipe
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(recipe.category.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)

                Spacer()

                if recipe.preparationTime > 0 {
                    Label("\(recipe.preparationTime) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if recipe.calories > 0 {
                    Label("\(Int(recipe.calories)) kcal", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(recipe.name)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}
