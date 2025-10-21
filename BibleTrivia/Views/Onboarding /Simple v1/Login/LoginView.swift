//
//  LoginView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 3.10.25.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(Router.self) private var router
    
    @State private var viewModel = LoginViewModel()
    @State private var loginTask: Task<(), Error>?
    
    @FocusState private var emailIsFocused: Bool
    @FocusState private var passwordIsFocused: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: Constants.vStackSpacing) {
            
            //Email
            VStack(alignment: .leading, spacing: Constants.vStackSpacing / 2) {
                NewBTTextField(
                    value: $viewModel.email,
                    isFocused: _emailIsFocused,
                    placeholder: "email",
                    keyboardType: .emailAddress,
                    contentType: .emailAddress
                )
                
                if viewModel.showEmailError {
                    Text("Invalid email")
                        .applyFont(.regular, size: 15, textColor: .red)
                        .animation(.bouncy, value: viewModel.showEmailError)
                }
            }
            .onChange(of: viewModel.email) { _, _ in
                withAnimation {
                    viewModel.validateEmail()
                }
            }
            
            //Pssowrd
            VStack(alignment: .leading, spacing: Constants.vStackSpacing / 2) {
                NewBTSecureField(
                    value: $viewModel.password,
                    isFocused: _passwordIsFocused,
                    placeholder: "password"
                )
                
                if viewModel.showPasswordError {
                    Text("Invalid password")
                        .applyFont(.regular, size: 15, textColor: .red)
                        .animation(.bouncy, value: viewModel.showEmailError)
                }
            }
            .onChange(of: viewModel.password) { _, _ in
                withAnimation {
                    viewModel.validatePassword()
                }
                
            }
            
            
            Button("Login") {
                onLogin()
            }
            .buttonStyle(.primary)
            .buttonDisabled(viewModel.loginDisabled)
            
            
            Button("Forgot password".uppercased()) {
                router.navigateTo(.forgotPassword)
            }
            .applyFont(.semiBold, size: 15, textColor: .blueGradient)
            
            
            Spacer()
            
        }
        
        .navigationBarBackButtonHidden()
        .onSubmit { onLogin() }
        .onDisappear { self.loginTask?.cancel() }
        .safeAreaInset(edge: .top) {
            CustomNavigationBar(
                title: "Enter your details",
                leftButtonAction: { router.popBackStack() }
            )
            .padding(.bottom, 16)
        }
        .safeAreaInset(edge: .bottom) {
            ProviderSignUpButtonsView { provider in
                authManager.alertManager.showFeatureCommingSoonAlert(for: "Sign with \(provider.rawValue.capitalized)")
            }
        }
        .applyViewPaddings(.all)
        .dismissKeyboardOnTap()
        .applyBackground()
    }
    
    private func onLogin() {
        self.loginTask = Task {
            await authManager.signIn(
                email: viewModel.email,
                password: viewModel.password
            )
        }
    }
}

#Preview {
    PreviewEnvironmentView {
        LoginView()
    }
}


struct ProviderSignUpButtonsView: View {
    var onSignUp: (Provider) -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: Constants.vStackSpacing) {
                ProviderLoginButton(provider: .apple,
                                    backgroundColor: .BTBackground,
                                    strokeColor: .BTStroke,
                                    strokeSize: 2,
                                    action: { onSignUp(.apple) }
                )
                
                ProviderLoginButton(provider: .google,
                                    backgroundColor: .BTBackground,
                                    strokeColor: .BTStroke,
                                    strokeSize: 2,
                                    action: { onSignUp(.google)}
                )
                
                Text("By signing in to BibleTrivia, you agree to our Terms and Privacy Policy.")
                    .applyFont(.regular, size: 12)
                    .multilineTextAlignment(.center)
        }
        .ignoresSafeArea(.keyboard)
        .applyViewPaddings(.horizontal)
    }
}
