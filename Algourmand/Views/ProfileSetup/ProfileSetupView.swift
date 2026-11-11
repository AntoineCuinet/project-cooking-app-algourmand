import AlgourmandCore
import AlgourmandCoreUI
import SwiftUI

struct ProfileSetupView: View {
    @StateObject private var viewModel = ProfileSetupViewModel()
    let onCompleted: (UserProfile) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                topNavigationBar

                ScrollView {
                    VStack(spacing: 24) {
                        stepHeader

                        stepCardContainer

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }

                bottomActionBar
            }
            .background(Color.algourmandBackground.ignoresSafeArea())
        }
    }

    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        VStack(spacing: 12) {
            HStack {
                if viewModel.canGoBack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.previousStep()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Retour")
                                .font(.subheadline)
                        }
                        .foregroundStyle(Color.algourmandText)
                    }
                } else {
                    Color.clear
                        .frame(width: 60, height: 24)
                }

                Spacer()

                Text("Étape \(viewModel.currentStepIndex + 1) sur \(viewModel.totalSteps)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.algourmandText.opacity(0.6))

                Spacer()

                Color.clear
                    .frame(width: 60, height: 24)
            }

            StepProgressBar(
                currentStep: viewModel.currentStepIndex,
                totalSteps: viewModel.totalSteps
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Step Header
    private var stepHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.algourmandPrimary.opacity(0.12))
                    .frame(width: 68, height: 68)

                Image(systemName: viewModel.currentStep.systemIcon)
                    .font(.system(size: 30))
                    .foregroundStyle(Color.algourmandPrimary)
            }

            VStack(spacing: 6) {
                Text(viewModel.currentStep.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.algourmandText)
                    .multilineTextAlignment(.center)

                Text(viewModel.currentStep.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.algourmandText.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Step Card Container
    private var stepCardContainer: some View {
        VStack(spacing: 20) {
            stepContent
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.algourmandPrimary.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    // MARK: - Step Content Switcher
    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .physicalInfo:
            PhysicalInfoStepView(viewModel: viewModel)
        case .nutritionGoal:
            NutritionGoalStepView(viewModel: viewModel)
        case .dietaryPreferences:
            DietaryPreferencesStepView(viewModel: viewModel)
        case .allergies:
            AllergiesStepView(viewModel: viewModel)
        case .dislikedIngredients:
            DislikedIngredientsStepView(viewModel: viewModel)
        }
    }

    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                if viewModel.canGoBack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.previousStep()
                        }
                    } label: {
                        Text("Précédent")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .frame(height: 20)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.algourmandText)
                    .controlSize(.large)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if viewModel.isLastStep {
                            viewModel.completeSetup()
                            let profile = viewModel.buildUserProfile()
                            onCompleted(profile)
                        } else {
                            viewModel.nextStep()
                        }
                    }
                } label: {
                    Text(viewModel.isLastStep ? "Terminer" : "Continuer")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.algourmandPrimary)
                .controlSize(.large)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(!viewModel.canProceedFromCurrentStep)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.algourmandBackground)
    }
}

#Preview {
    ProfileSetupView { _ in }
}
