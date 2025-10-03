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
    
    @State private var email = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.rotation")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("Reset Password")
                .font(.title)
                .bold()
            
            Text("Enter your email and we'll send you a link to reset your password")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding()
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
            
            Button("Send Reset Email") {
                Task {
                    await authManager.sendPasswordResetEmail(email: email) {
                        // Go back to login
                        router.popBackStack()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty)
            
            Spacer()
            
            Button("Back to Login") {
                router.navigateToAndClearBackstack(to: .login)
            }
        }
        .padding()
    }
}
