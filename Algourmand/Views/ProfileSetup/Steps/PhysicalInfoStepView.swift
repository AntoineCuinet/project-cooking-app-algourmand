import AlgourmandCore
import AlgourmandCoreUI
import SwiftUI

struct PhysicalInfoStepView: View {
    @ObservedObject var viewModel: ProfileSetupViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            measurementsSection
            activityLevelSection
        }
    }

    // MARK: - Measurements Section
    private var measurementsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Vos mesures physiques")
                .font(.headline)
                .foregroundStyle(Color.algourmandText)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Âge")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.algourmandText.opacity(0.8))

                    Text("*")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.algourmandPrimary)
                }

                measurementInputField(
                    title: "Ex. 28",
                    text: $viewModel.ageText,
                    unit: "ans",
                    keyboardType: .numberPad,
                    isValid: viewModel.ageText.isEmpty || viewModel.isAgeValid
                )

                if !viewModel.ageText.isEmpty && !viewModel.isAgeValid {
                    Text("L'âge doit être compris entre 10 et 120 ans.")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Taille (optionnel)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.algourmandText.opacity(0.8))

                    measurementInputField(
                        title: "Ex. 175",
                        text: $viewModel.heightText,
                        unit: "cm",
                        keyboardType: .decimalPad,
                        isValid: viewModel.isHeightValid
                    )

                    if !viewModel.heightText.isEmpty && !viewModel.isHeightValid {
                        Text("Entre 50 et 260 cm")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Poids (optionnel)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.algourmandText.opacity(0.8))

                    measurementInputField(
                        title: "Ex. 70",
                        text: $viewModel.weightText,
                        unit: "kg",
                        keyboardType: .decimalPad,
                        isValid: viewModel.isWeightValid
                    )

                    if !viewModel.weightText.isEmpty && !viewModel.isWeightValid {
                        Text("Entre 20 et 350 kg")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }

    private func measurementInputField(
        title: String,
        text: Binding<String>,
        unit: String,
        keyboardType: UIKeyboardType,
        isValid: Bool
    ) -> some View {
        HStack {
            TextField(title, text: text)
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
                .font(.body)

            Text(unit)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.algourmandText.opacity(0.6))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.algourmandBackground)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isValid ? Color.clear : Color.red.opacity(0.6),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Activity Level Section
    private var activityLevelSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Niveau d'activité habituel")
                    .font(.headline)
                    .foregroundStyle(Color.algourmandText)

                Text("Permet de calibrer les recommandations de portions et de calories.")
                    .font(.caption)
                    .foregroundStyle(Color.algourmandText.opacity(0.7))
            }

            VStack(spacing: 10) {
                ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { level in
                    SelectionCard(
                        title: level.displayName,
                        description: level.subtitle,
                        systemImage: level.systemIcon,
                        isSelected: viewModel.activityLevel == level
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.activityLevel = level
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PhysicalInfoStepView(viewModel: ProfileSetupViewModel())
        .padding()
        .background(Color.algourmandBackground)
}
