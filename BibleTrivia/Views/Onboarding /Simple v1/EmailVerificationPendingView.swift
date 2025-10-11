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
    
    @State private var effect: Bool = false
    @State private var otpCode: String = ""
    @State private var isVerifying: Bool = false
    let email: String
    
    var body: some View {
        VStack(alignment: .center, spacing: Constants.vStackSpacing) {
            Image(systemName: "envelope.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(Color.BTPrimary)
                .symbolEffect(.wiggle, value: effect)
            
            Text("Check Your Email")
                .applyFont(.semiBold, size: 32, textColor: .BTBlack)
            
            Text("We sent a confirmation link to:")
                .applyFont(.regular, size: 18, textColor: .BTLightGray)
            
            Text(email)
                .applyFont(.medium, size: 20, textColor: .BTPrimary)
            
            Text("Click the link in the email to verify your account")
                .applyFont(.regular, size: 18, textColor: .BTLightGray)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 15) {
                Text("Enter Verification Code")
                    .font(.headline)
                
                // OTP Code Input
                TextField("000000", text: $otpCode)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .frame(height: 60)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .onChange(of: otpCode) { oldValue, newValue in
                        // Limit to 6 digits
                        if newValue.count > 6 {
                            otpCode = String(newValue.prefix(6))
                        }
                        // Auto-verify when 6 digits entered
                        if newValue.count == 6 {
                            verifyCode()
                        }
                    }
                
                // Verify Button
                Button(action: verifyCode) {
                    if isVerifying {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Verify Code")
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(otpCode.count == 6 ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(otpCode.count != 6 || isVerifying)
            }
            .padding()
            
            Spacer()
            
            Divider()
                .padding()
            
            VStack(spacing: 8) {
                Text("Didn't receive the email?")
                    .applyFont(.regular, size: 17, textColor: .BTLightGray)
                
                Button("Resend Confirmation Email") {
                    Task {
                        effect.toggle()
                        await authManager.resendConfirmationEmail(email: email)
                    }
                }
                .applyFont(.semiBold, size: 17, textColor: .BTPrimary)
            }
            
            Button("Back to Login") {
                router.popToRoot()
                router.navigateTo(.login)
            }
            .applyFont(.semiBold, size: 16, textColor: .BTBlack)
            .buttonStyle(.borderedProminent)
            .tint(.BTStroke)
            
            
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard)
        .onAppear { effect.toggle() }
        .applyViewPaddings(.all)
        .applyBackground()
    }
    
    private func verifyCode() {
        guard otpCode.count == 6 else { return }
        
        isVerifying = true
        
        Task {
            await authManager.verifyEmailWithCode(email: email, code: otpCode) {
                // Success - pop to root, listenAuthEvents will handle navigation
                router.popToRoot()
            }
            isVerifying = false
        }
    }
}

#Preview {
    PreviewEnvironmentView {
        EmailVerificationPendingView(email: "test@test.com")
    }
}
