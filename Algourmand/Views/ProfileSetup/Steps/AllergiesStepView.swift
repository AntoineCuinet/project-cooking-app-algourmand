import AlgourmandCore
import AlgourmandCoreUI
import SwiftUI

struct AllergiesStepView: View {
    @ObservedObject var viewModel: ProfileSetupViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection
            allergiesList
            securityNotice
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Allergies et intolérances")
                    .font(.headline)
                    .foregroundStyle(Color.algourmandText)

                Spacer()

                if !viewModel.selectedAllergies.isEmpty {
                    Button("Tout désélectionner") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.clearAllergies()
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(Color.algourmandPrimary)
                }
            }

            Text("Indiquez vos intolérances pour sécuriser automatiquement vos suggestions.")
                .font(.caption)
                .foregroundStyle(Color.algourmandText.opacity(0.7))
        }
    }

    private var allergiesList: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.availableAllergies) { item in
                SelectionCard(
                    title: item.title,
                    description: nil,
                    systemImage: item.systemIcon,
                    isSelected: viewModel.isAllergySelected(item.id)
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.toggleAllergy(item.id)
                    }
                }
            }
        }
    }

    private var securityNotice: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "shield.lefthalf.filled")
                .foregroundStyle(Color.algourmandPrimary)
                .font(.subheadline)

            Text("Les recettes contenant ces ingrédients seront strictement exclues de vos plannings.")
                .font(.caption)
                .foregroundStyle(Color.algourmandText.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.algourmandPrimary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AllergiesStepView(viewModel: ProfileSetupViewModel())
        .padding()
        .background(Color.algourmandBackground)
}
