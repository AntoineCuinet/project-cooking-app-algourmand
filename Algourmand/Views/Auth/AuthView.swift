import AlgourmandCore
import SwiftUI
import UIKit

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel

    @State private var selectedTab: AuthTab = .login

    // Login Form State
    @State private var loginEmail = ""
    @State private var loginPassword = ""

    // Register Form State
    @State private var registerUsername = ""
    @State private var registerEmail = ""
    @State private var registerPassword = ""
    @State private var registerPasswordConfirmation = ""

    private enum AuthTab: String, CaseIterable, Identifiable {
        case login = "Connexion"
        case register = "Inscription"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection

                    authCard

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 96, height: 96)

                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.orange)
            }

            VStack(spacing: 4) {
                Text("Algourmand")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text("Vos recettes et repas au quotidien")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 20)
    }

    // MARK: - Auth Card
    private var authCard: some View {
        VStack(spacing: 20) {
            Picker("Mode d'authentification", selection: $selectedTab) {
                ForEach(AuthTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedTab) { _ in
                viewModel.clearMessages()
            }

            if let errorMessage = viewModel.errorMessage {
                errorBanner(message: errorMessage)
            }

            if selectedTab == .login {
                loginForm
            } else {
                registerForm
            }
        }
        .padding(20)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    // MARK: - Login Form
    private var loginForm: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Adresse email")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                TextField("nom@exemple.com", text: $loginEmail)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Mot de passe")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                SecureField("Mot de passe", text: $loginPassword)
                    .textFieldStyle(.roundedBorder)
            }

            // button easy filling for mock
            Button {
                loginEmail = "quentin@algourmand.ch"
                loginPassword = "password123"
            } label: {
                Text("Utiliser le compte de test")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            Button {
                Task {
                    await viewModel.login(email: loginEmail, password: loginPassword)
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                } else {
                    Text("Se connecter")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .controlSize(.large)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(viewModel.isLoading || loginEmail.isEmpty || loginPassword.isEmpty)
        }
    }

    // MARK: - Register Form
    private var registerForm: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Nom d'utilisateur")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                TextField("ex: chef_quentin", text: $registerUsername)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Adresse email")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                TextField("nom@exemple.com", text: $registerEmail)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Mot de passe")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                SecureField("Mot de passe", text: $registerPassword)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Confirmer le mot de passe")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                SecureField("Confirmation", text: $registerPasswordConfirmation)
                    .textFieldStyle(.roundedBorder)
            }

            Button {
                Task {
                    await viewModel.register(
                        username: registerUsername,
                        email: registerEmail,
                        password: registerPassword,
                        passwordConfirmation: registerPasswordConfirmation
                    )
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                } else {
                    Text("S'inscrire")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .controlSize(.large)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(
                viewModel.isLoading ||
                registerEmail.isEmpty ||
                registerPassword.isEmpty ||
                registerUsername.isEmpty
            )
        }
    }

    // MARK: - Error Banner
    private func errorBanner(message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)

            Spacer()
        }
        .padding(12)
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel())
}
