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
                    .foregroundStyle(Color.algourmandSecondary)

                Spacer()

                if recipe.preparationTime > 0 {
                    Label("\(recipe.preparationTime) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(Color.algourmandText.opacity(0.7))
                }

                if recipe.calories > 0 {
                    Label("\(Int(recipe.calories)) kcal", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(Color.algourmandPrimary)
                }
            }

            Text(recipe.name)
                .font(.headline)
                .foregroundStyle(Color.algourmandText)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.algourmandPrimary.opacity(0.12), lineWidth: 1)
        )
    }
}
