import AlgourmandCore
import AlgourmandCoreUI
import SwiftUI

struct DietaryPreferencesStepView: View {
    @ObservedObject var viewModel: ProfileSetupViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection
            preferencesList
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Quel est votre régime alimentaire ?")
                .font(.headline)
                .foregroundStyle(Color.algourmandText)

            Text("Sélectionnez les habitudes alimentaires qui vous correspondent (choix multiple possible).")
                .font(.caption)
                .foregroundStyle(Color.algourmandText.opacity(0.7))
        }
    }

    private var preferencesList: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.availableDietaryPreferences) { item in
                SelectionCard(
                    title: item.title,
                    description: item.subtitle,
                    systemImage: item.systemIcon,
                    isSelected: viewModel.isDietaryPreferenceSelected(item.id)
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.toggleDietaryPreference(item.id)
                    }
                }
            }
        }
    }
}

#Preview {
    DietaryPreferencesStepView(viewModel: ProfileSetupViewModel())
        .padding()
        .background(Color.algourmandBackground)
}
