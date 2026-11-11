import SwiftUI

public struct StepProgressBar: View {
    public let currentStep: Int
    public let totalSteps: Int

    public init(currentStep: Int, totalSteps: Int) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? Color.algourmandPrimary : Color.algourmandPrimary.opacity(0.2))
                    .frame(height: 6)
                    .animation(.easeInOut(duration: 0.25), value: currentStep)
            }
        }
    }
}
