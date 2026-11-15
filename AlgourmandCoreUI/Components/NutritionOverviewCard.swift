import AlgourmandCore
import SwiftUI

public struct NutritionOverviewCard: View {
    public let needs: NutritionNeeds

    public init(needs: NutritionNeeds) {
        self.needs = needs
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection

            heroCaloriesSection

            macroBreakdownSection

            lifestyleBadgesSection
        }
        .padding(18)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Mes besoins journaliers")
                .font(.headline)
                .foregroundStyle(Color.algourmandText)

            Text("\(needs.goalTitle) • \(needs.activityTitle)")
                .font(.caption)
                .foregroundStyle(Color.algourmandText.opacity(0.7))
        }
    }

    // MARK: - Hero Calories Section
    private var heroCaloriesSection: some View {
        HStack(alignment: .center, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(needs.targetCalories))")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.algourmandPrimary)

                Text("kcal / jour")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.algourmandText.opacity(0.7))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)

            Spacer()

            if let bmi = needs.bmi, let category = needs.bmiCategory {
                HStack(spacing: 5) {
                    Image(systemName: category.systemIcon)
                        .font(.caption2)
                    Text("IMC \(String(format: "%.1f", bmi))")
                        .font(.caption)
                        .fontWeight(.bold)
                    Text("• \(category.shortBadge)")
                        .font(.caption2)
                }
                .lineLimit(1)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(bmiBadgeColor(category).opacity(0.15))
                .foregroundStyle(bmiBadgeColor(category))
                .clipShape(Capsule())
            }
        }
    }

    // MARK: - Macro Breakdown Section
    private var macroBreakdownSection: some View {
        VStack(spacing: 10) {
            GeometryReader { geometry in
                HStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.orange)
                        .frame(width: max(geometry.size.width * CGFloat(needs.proteinsPercentage / 100.0), 4))

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.yellow.opacity(0.9))
                        .frame(width: max(geometry.size.width * CGFloat(needs.fatsPercentage / 100.0), 4))

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.teal)
                        .frame(width: max(geometry.size.width * CGFloat(needs.carbohydratesPercentage / 100.0), 4))
                }
            }
            .frame(height: 6)

            // 3 macros columns
            HStack(spacing: 8) {
                macroTile(
                    title: "Protéines",
                    grams: needs.proteinsGrams,
                    calories: needs.proteinsCalories,
                    percentage: needs.proteinsPercentage,
                    color: .orange
                )

                macroTile(
                    title: "Lipides",
                    grams: needs.fatsGrams,
                    calories: needs.fatsCalories,
                    percentage: needs.fatsPercentage,
                    color: .yellow
                )

                macroTile(
                    title: "Glucides",
                    grams: needs.carbohydratesGrams,
                    calories: needs.carbohydratesCalories,
                    percentage: needs.carbohydratesPercentage,
                    color: .teal
                )
            }
        }
    }

    private func macroTile(
        title: String,
        grams: Double,
        calories: Double,
        percentage: Double,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)

                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.algourmandText.opacity(0.7))
            }

            Text("\(Int(grams)) g")
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(Color.algourmandText)

            Text("\(Int(percentage))% • \(Int(calories)) kcal")
                .font(.system(size: 10))
                .foregroundStyle(Color.algourmandText.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Lifestyle Badges Section
    private var lifestyleBadgesSection: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "drop.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
                Text("\(String(format: "%.1f", needs.waterLiters)) L d'eau")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.algourmandText.opacity(0.8))
            }

            HStack(spacing: 6) {
                Image(systemName: "leaf.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                Text("\(Int(needs.fiberGrams)) g de fibres")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.algourmandText.opacity(0.8))
            }

            Spacer()

            if needs.calorieAdjustment != 0 {
                let isSurplus = needs.calorieAdjustment > 0
                Text("\(isSurplus ? "+" : "")\(Int(needs.calorieAdjustment)) kcal vs maintien")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isSurplus ? Color.algourmandPrimary : Color.orange)
            }
        }
        .padding(.top, 4)
    }

    private func bmiBadgeColor(_ category: BMICategory) -> Color {
        switch category {
        case .normal: return .green
        case .underweight: return .blue
        case .overweight: return .orange
        case .obeseClass1, .obeseClass2: return .red
        }
    }
}
