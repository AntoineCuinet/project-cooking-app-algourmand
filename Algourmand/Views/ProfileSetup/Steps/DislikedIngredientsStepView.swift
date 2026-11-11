import AlgourmandCore
import AlgourmandCoreUI
import SwiftUI

struct DislikedIngredientsStepView: View {
    @ObservedObject var viewModel: ProfileSetupViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // TODO: create sections
        }
    }
    
    // MARK: -
}

#Preview {
    DislikedIngredientsStepView(viewModel: ProfileSetupViewModel())
        .padding()
        .background(Color.algourmandBackground)
}
