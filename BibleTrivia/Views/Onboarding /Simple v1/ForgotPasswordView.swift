//
//  ForgotPasswordView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 3.10.25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(Router.self) private var router
    
    @FocusState private var emailIsFocused: Bool
    @State private var email = ""
    @State private var effect: Bool = false
    
    private var isValidEmail: Bool {
        Validations.isValid(email: email)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: Constants.vStackSpacing) {
            Image(systemName: "lock.rotation")
                .font(.system(size: 100))
                .foregroundStyle(Color.BTPrimary)
                .symbolEffect(.rotate, value: effect)
            
            Text("Reset Password")
                .applyFont(.semiBold, size: 32, textColor: .BTBlack)
            
            Text("Enter your email and we'll send you a link to reset your password")
                .applyFont(.regular, size: 18, textColor: .BTLightGray)
                .multilineTextAlignment(.center)
                .padding(5)
            
            NewBTTextField(
                value: $email,
                isFocused: _emailIsFocused,
                placeholder: "email",
                keyboardType: .emailAddress,
                contentType: .emailAddress
            )
            
            Button("Send Reset Email") {
                Task {
                    effect.toggle()
                    await authManager.sendPasswordResetEmail(email: email) {
                        // Go back to login
                        router.popBackStack()
                    }
                }
            }
            .buttonStyle(.primary)
            .disabled(!isValidEmail)
            
            Spacer()
            
            Button("Back to Login") {
                router.navigateToAndClearBackstack(to: .welcome)
                router.navigateTo(.login)
            }
            .applyFont(.semiBold, size: 16, textColor: .BTBlack)
            .buttonStyle(.borderedProminent)
            .tint(.BTStroke)
        }
        .applyBackground()
        .applyViewPaddings(.all)
        .dismissKeyboardOnTap()
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard)
        .onAppear { effect.toggle() }
    }
}

#Preview {
    PreviewEnvironmentView {
        ForgotPasswordView()
    }
}
