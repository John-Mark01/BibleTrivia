//
//  ForgotPasswordView.swift
//  BibleTrivia
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(Router.self) private var router

    @FocusState private var emailIsFocused: Bool
    @State private var email = ""
    @State private var effect = false

    private var trimmedEmail: String { email.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        VStack(alignment: .center, spacing: Constants.vStackSpacing) {
            Image(systemName: "lock.rotation")
                .font(.system(size: 100))
                .foregroundStyle(.btPrimary)
                .symbolEffect(.rotate, value: effect)
                .accessibilityHidden(true)

            Text("Reset Password")
                .applyFont(.semiBold, size: 32, textColor: .btBlack)

            Text("Enter your email and we'll send you a link to reset your password")
                .applyFont(.regular, size: 18, textColor: .btLightGray)
                .multilineTextAlignment(.center)
                .padding(5)

            BTTextField(
                value: $email,
                isFocused: $emailIsFocused,
                placeholder: "email",
                keyboardType: .emailAddress,
                contentType: .emailAddress
            )

            Button("Send Reset Email") {
                effect.toggle()
                Task {
                    if await authManager.sendPasswordResetEmail(email: trimmedEmail) {
                        router.pop()
                    }
                }
            }
            .buttonStyle(.primary)
            .buttonDisabled(!Validation.isValid(email: trimmedEmail))

            Spacer()

            Button("Back to Login") {
                router.reset(to: .login)
            }
            .applyFont(.semiBold, size: 16, textColor: .btBlack)
            .buttonStyle(.borderedProminent)
            .tint(.btStroke)
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard)
        .onAppear { effect.toggle() }
        .applyViewPaddings(.all)
        .dismissKeyboardOnTap()
        .applyBackground()
    }
}

#Preview {
    PreviewEnvironment(app: .preview(loadData: false)) {
        ForgotPasswordView()
    }
}
