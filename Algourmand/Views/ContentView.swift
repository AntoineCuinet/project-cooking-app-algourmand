import AlgourmandCore
import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if !authViewModel.isAuthenticated {
                AuthView(viewModel: authViewModel)
                    .transition(.opacity)
            } else if !authViewModel.hasCompletedProfile {
                ProfileSetupView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        authViewModel.markProfileCompleted()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
            } else {
                HomeView(viewModel: authViewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: authViewModel.isAuthenticated)
        .animation(.easeInOut(duration: 0.25), value: authViewModel.hasCompletedProfile)
    }
}

#Preview {
    ContentView()
}
