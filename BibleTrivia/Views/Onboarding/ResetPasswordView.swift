//
//  ResetPasswordView.swift
//  BibleTrivia
//

import SwiftUI

/// Presented as a sheet after the user opens a password-reset link.
struct ResetPasswordView: View {
    @Environment(AuthManager.self) private var authManager

    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @FocusState private var newIsFocused: Bool
    @FocusState private var confirmIsFocused: Bool

    private var passwordsMatch: Bool { newPassword == confirmPassword }
    private var canSubmit: Bool { Validation.isValid(password: newPassword) && passwordsMatch }

    var body: some View {
        VStack(spacing: Constants.vStackSpacing) {
            Text("Create New Password")
                .applyFont(.semiBold, size: 28)
                .padding(.top, 32)

            Text("At least 8 characters, with an uppercase letter, a lowercase letter and a number.")
                .applyFont(.regular, size: 15, textColor: .btLightGray)
                .multilineTextAlignment(.center)

            BTSecureField(value: $newPassword, isFocused: $newIsFocused,
                          placeholder: "new password", contentType: .newPassword)
            BTSecureField(value: $confirmPassword, isFocused: $confirmIsFocused,
                          placeholder: "confirm password", contentType: .newPassword)

            if !confirmPassword.isEmpty && !passwordsMatch {
                FieldError("Passwords don't match")
            }

            Button("Update Password") {
                Task { await authManager.updatePassword(newPassword) }
            }
            .buttonStyle(.primary)
            .buttonDisabled(!canSubmit)

            Spacer()
        }
        .applyViewPaddings()
        .applyBackground()
        .interactiveDismissDisabled()
        .dismissKeyboardOnTap()
    }
}

#Preview {
    PreviewEnvironment(app: .preview(loadData: false)) {
        ResetPasswordView()
    }
}
