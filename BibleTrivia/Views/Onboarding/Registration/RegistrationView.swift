//
//  RegistrationView.swift
//  BibleTrivia
//

import SwiftUI

struct RegistrationView: View {
    @Environment(Router.self) private var router
    @Environment(AuthManager.self) private var authManager

    @State private var viewModel = RegistrationViewModel()

    @FocusState private var firstNameIsFocused: Bool
    @FocusState private var lastNameIsFocused: Bool
    @FocusState private var ageIsFocused: Bool
    @FocusState private var emailIsFocused: Bool
    @FocusState private var passwordIsFocused: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: Constants.vStackSpacing) {
                field(error: viewModel.firstNameError) {
                    BTTextField(value: $viewModel.firstName, isFocused: $firstNameIsFocused,
                                placeholder: "first name", contentType: .givenName, autocapitalization: .words)
                }
                field(error: viewModel.lastNameError) {
                    BTTextField(value: $viewModel.lastName, isFocused: $lastNameIsFocused,
                                placeholder: "last name", contentType: .familyName, autocapitalization: .words)
                }
                field(error: viewModel.ageError) {
                    BTTextField(value: $viewModel.age, isFocused: $ageIsFocused,
                                placeholder: "age", keyboardType: .numberPad)
                }
                field(error: viewModel.emailError) {
                    BTTextField(value: $viewModel.email, isFocused: $emailIsFocused,
                                placeholder: "email", keyboardType: .emailAddress, contentType: .emailAddress)
                }
                field(error: viewModel.passwordError) {
                    BTSecureField(value: $viewModel.password, isFocused: $passwordIsFocused,
                                  placeholder: "password", contentType: .newPassword)
                }

                Button("Sign Up", action: signUp)
                    .padding(.top, Constants.vStackSpacing)
                    .buttonStyle(.primary)
                    .buttonDisabled(!viewModel.canSubmit)

                Button("Already have an account? Sign In") {
                    router.reset(to: .login)
                }

                Spacer()
            }
        }
        .onSubmit(onSubmit)
        .scrollBounceBehavior(.basedOnSize)
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard)
        .safeAreaInset(edge: .top) {
            CustomNavigationBar(title: "Welcome to BibleTrivia!", leftButtonAction: { router.pop() })
        }
        .applyViewPaddings(.all)
        .dismissKeyboardOnTap()
        .applyBackground()
    }

    private func field(error: LocalizedStringResource?, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Constants.vStackSpacing / 2) {
            content()
            if let error {
                Text(error)
                    .applyFont(.regular, size: 15, textColor: .red)
                    .transition(.opacity)
            }
        }
        .animation(.bouncy, value: error == nil)
    }

    private func signUp() {
        guard viewModel.canSubmit, let age = Int(viewModel.age) else { return }
        let email = viewModel.trimmedEmail
        Task {
            let created = await authManager.signUp(
                email: email,
                password: viewModel.password,
                firstName: viewModel.firstName.trimmingCharacters(in: .whitespaces),
                lastName: viewModel.lastName.trimmingCharacters(in: .whitespaces),
                age: age
            )
            if created {
                router.navigate(to: .emailVerificationPending(email: email))
            }
        }
    }

    private func onSubmit() {
        if firstNameIsFocused {
            lastNameIsFocused = true
        } else if lastNameIsFocused {
            ageIsFocused = true
        } else if ageIsFocused {
            emailIsFocused = true
        } else if emailIsFocused {
            passwordIsFocused = true
        } else {
            signUp()
        }
    }
}

#Preview {
    PreviewEnvironment(app: .preview(loadData: false)) {
        RegistrationView()
    }
}
