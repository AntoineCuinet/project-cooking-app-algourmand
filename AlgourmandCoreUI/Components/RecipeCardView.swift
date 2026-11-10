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

                Label("\(recipe.prepTimeMinutes) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(recipe.title)
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
