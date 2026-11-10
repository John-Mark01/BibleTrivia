//
//  EmailVerificationPendingView.swift
//  BibleTrivia
//

import SwiftUI

struct EmailVerificationPendingView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(Router.self) private var router

    let email: String

    @State private var effect = false
    @State private var otpCode = ""
    @State private var isVerifying = false
    @FocusState private var codeIsFocused: Bool

    private static let codeLength = 6

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: Constants.vStackSpacing) {
                Image(systemName: "envelope.circle.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.btPrimary)
                    .symbolEffect(.wiggle, value: effect)
                    .accessibilityHidden(true)

                Text("Check Your Email")
                    .applyFont(.semiBold, size: 32, textColor: .btBlack)

                Text("We sent a confirmation link and code to:")
                    .applyFont(.regular, size: 18, textColor: .btLightGray)
                    .multilineTextAlignment(.center)

                Text(email)
                    .applyFont(.medium, size: 20, textColor: .btPrimary)

                VStack(spacing: 15) {
                    Text("Enter the 6-digit code")
                        .applyFont(.medium, size: 17)

                    TextField("000000", text: $otpCode)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .frame(height: 60)
                        .background(.gray.opacity(0.1))
                        .clipShape(.rect(cornerRadius: 12))
                        .focused($codeIsFocused)
                        .onChange(of: otpCode) { _, newValue in
                            let digits = String(newValue.filter(\.isNumber).prefix(Self.codeLength))
                            if digits != newValue { otpCode = digits }
                            if digits.count == Self.codeLength { verifyCode() }
                        }

                    Button(action: verifyCode) {
                        if isVerifying {
                            ProgressView().tint(.white)
                        } else {
                            Text("Verify Code")
                        }
                    }
                    .buttonStyle(.primary)
                    .buttonDisabled(otpCode.count != Self.codeLength || isVerifying)
                }
                .padding(.vertical)

                Divider()

                VStack(spacing: 8) {
                    Text("Didn't receive the email?")
                        .applyFont(.regular, size: 17, textColor: .btLightGray)

                    Button("Resend Confirmation Email") {
                        effect.toggle()
                        Task { await authManager.resendConfirmationEmail(email: email) }
                    }
                    .applyFont(.semiBold, size: 17, textColor: .btPrimary)
                }

                Button("Back to Login") {
                    router.reset(to: .login)
                }
                .applyFont(.semiBold, size: 16, textColor: .btBlack)
                .buttonStyle(.borderedProminent)
                .tint(.btStroke)
                .padding(.top)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear { effect.toggle() }
        .applyViewPaddings(.all)
        .dismissKeyboardOnTap()
        .applyBackground()
    }

    private func verifyCode() {
        guard otpCode.count == Self.codeLength, !isVerifying else { return }
        isVerifying = true
        codeIsFocused = false
        Task {
            // On success the auth listener signs the user in and RootView switches to the app.
            await authManager.verifyEmail(email: email, code: otpCode)
            isVerifying = false
        }
    }
}

#Preview {
    PreviewEnvironment(app: .preview(loadData: false)) {
        EmailVerificationPendingView(email: "test@test.com")
    }
}
