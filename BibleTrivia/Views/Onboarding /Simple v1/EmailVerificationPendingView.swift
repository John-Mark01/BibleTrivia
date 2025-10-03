//
//  EmailVerificationPendingView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 3.10.25.
//

import SwiftUI

struct EmailVerificationPendingView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(Router.self) private var router
    
    let email: String
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "envelope.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("Check Your Email")
                .font(.title)
                .bold()
            
            Text("We sent a confirmation link to:")
                .foregroundStyle(.secondary)
            
            Text(email)
                .font(.headline)
                .foregroundStyle(.blue)
            
            Text("Click the link in the email to verify your account")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Divider()
                .padding()
            
            VStack(spacing: 15) {
                Text("Didn't receive the email?")
                    .foregroundStyle(.secondary)
                
                Button("Resend Confirmation Email") {
                    Task {
                        await authManager.resendConfirmationEmail(email: email)
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            Button("Back to Login") {
                router.navigateToAndClearBackstack(to: .login)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
