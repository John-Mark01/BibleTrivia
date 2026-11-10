//
//  LoginView.swift
//  BibleTrivia
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AlertManager.self) private var alertManager
    @Environment(Router.self) private var router

    @State private var viewModel = LoginViewModel()

    @FocusState private var emailIsFocused: Bool
    @FocusState private var passwordIsFocused: Bool

    var body: some View {
        VStack(alignment: .center, spacing: Constants.vStackSpacing) {
            VStack(alignment: .leading, spacing: Constants.vStackSpacing / 2) {
                BTTextField(
                    value: $viewModel.email,
                    isFocused: $emailIsFocused,
                    placeholder: "email",
                    keyboardType: .emailAddress,
                    contentType: .emailAddress
                )
                .submitLabel(.next)

                if viewModel.showEmailError {
                    FieldError("Invalid email")
                }
            }

            BTSecureField(
                value: $viewModel.password,
                isFocused: $passwordIsFocused,
                placeholder: "password"
            )
            .submitLabel(.go)

            Button("Login", action: login)
                .buttonStyle(.primary)
                .buttonDisabled(!viewModel.canSubmit)

            Button("Forgot password".uppercased()) {
                router.navigate(to: .forgotPassword)
            }
            .applyFont(.semiBold, size: 15, textColor: .blueGradient)

            Spacer()
        }
        .animation(.bouncy, value: viewModel.showEmailError)
        .navigationBarBackButtonHidden()
        .onSubmit(onSubmit)
        .safeAreaInset(edge: .top) {
            CustomNavigationBar(title: "Enter your details", leftButtonAction: { router.pop() })
        }
        .overlay(alignment: .bottom) {
            ProviderSignUpButtonsView { provider in
                alertManager.showFeatureComingSoonAlert(for: "Sign in with \(provider.rawValue)")
            }
        }
        .applyViewPaddings(.all)
        .applyBackground()
        .ignoresSafeArea(.keyboard)
        .dismissKeyboardOnTap()
    }

    private func login() {
        guard viewModel.canSubmit else { return }
        Task {
            await authManager.signIn(email: viewModel.trimmedEmail, password: viewModel.password)
        }
    }

    private func onSubmit() {
        if emailIsFocused {
            passwordIsFocused = true
        } else if passwordIsFocused {
            login()
        }
    }
}

/// Red validation message under a field.
struct FieldError: View {
    let message: LocalizedStringKey

    init(_ message: LocalizedStringKey) {
        self.message = message
    }

    var body: some View {
        Text(message)
            .applyFont(.regular, size: 15, textColor: .red)
            .transition(.opacity)
    }
}

struct ProviderSignUpButtonsView: View {
    var onSignUp: (Provider) -> Void

    var body: some View {
        VStack(alignment: .center, spacing: Constants.vStackSpacing) {
            ProviderLoginButton(provider: .apple, backgroundColor: .btBackground, strokeColor: .btStroke, strokeSize: 2) {
                onSignUp(.apple)
            }

            ProviderLoginButton(provider: .google, backgroundColor: .btBackground, strokeColor: .btStroke, strokeSize: 2) {
                onSignUp(.google)
            }

            Text("By signing in to BibleTrivia, you agree to our Terms and Privacy Policy.")
                .applyFont(.regular, size: 12)
                .multilineTextAlignment(.center)
        }
        .applyViewPaddings(.horizontal)
    }
}

#Preview {
    PreviewEnvironment(app: .preview(loadData: false)) {
        LoginView()
    }
}
