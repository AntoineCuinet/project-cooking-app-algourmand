import AlgourmandCore
import AlgourmandCoreUI
import SwiftUI

struct NutritionGoalStepView: View {
    @ObservedObject var viewModel: ProfileSetupViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            goalSection
        }
    }

    // MARK: - Goal Section
    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Quel est votre objectif ?")
                    .font(.headline)
                    .foregroundStyle(Color.algourmandText)

                Text("Permet de calibrer l'apport calorique et la répartition des protéines, glucides et lipides.")
                    .font(.caption)
                    .foregroundStyle(Color.algourmandText.opacity(0.7))
            }

            VStack(spacing: 10) {
                ForEach(UserProfile.NutritionGoal.allCases, id: \.self) { goal in
                    SelectionCard(
                        title: goal.displayName,
                        description: goal.subtitle,
                        systemImage: goal.systemIcon,
                        isSelected: viewModel.nutritionGoal == goal
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.nutritionGoal = goal
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NutritionGoalStepView(viewModel: ProfileSetupViewModel())
        .padding()
        .background(Color.algourmandBackground)
}
