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
        VStack(alignment: .center, spacing: Constants.vStackSpacing) {
            Image(systemName: "envelope.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(Color.BTPrimary)
            
            Text("Check Your Email")
                .applyFont(.semiBold, size: 32, textColor: .BTBlack)
            
            Text("We sent a confirmation link to:")
                .applyFont(.regular, size: 18, textColor: .BTLightGray)
            
            Text(email)
                .applyFont(.medium, size: 20, textColor: .BTPrimary)
            
            Text("Click the link in the email to verify your account")
                .applyFont(.regular, size: 18, textColor: .BTLightGray)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Divider()
                .padding()
            
            VStack(spacing: 15) {
                Text("Didn't receive the email?")
                    .applyFont(.regular, size: 17, textColor: .BTLightGray)
                
                Button("Resend Confirmation Email") {
                    Task {
                        await authManager.resendConfirmationEmail(email: email)
                    }
                }
                .applyFont(.semiBold, size: 16, textColor: .BTPrimary)
                .buttonStyle(.bordered)
            }
            
            Button("Back to Login") {
                router.navigateToAndClearBackstack(to: .welcome)
                router.navigateTo(.login)
            }
            .buttonStyle(.bordered)
            .applyFont(.semiBold, size: 16, textColor: .BTBlack)

            
        }
        .applyBackground()
        .applyViewPaddings(.all)
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    PreviewEnvironmentView {
        EmailVerificationPendingView(email: "test@test.com")
    }
}
