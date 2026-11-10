import AlgourmandCore
import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                HomeView(viewModel: authViewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                AuthView(viewModel: authViewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: authViewModel.isAuthenticated)
    }
}

#Preview {
    ContentView()
}
