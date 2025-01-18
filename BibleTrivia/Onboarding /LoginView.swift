//
//  LoginView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 18.01.25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var router: Router
    @Environment(UserManager.self) var userManager
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var loginDisabled: Bool = false
    
    func onForgotPasscode() {
        
    }
    func onLoginWithEmailAndPassword() {
        dismissKeyboard()
        Task {
            try? await userManager.signIn(email: email, password: password) { success in
                if success {
                    router.navigateToRoot()
                }
            }
        }
    }
    func onLoginWithApple() {
        
    }
    func onLoginWithGoogle() {
        
    }
    
    var body: some View {

        VStack(alignment: .center, spacing: 16) {
            
            CustomNavigationBar(title: "Enter your details",
                                leftButtonAction: {
                print("Navigate back")
                    router.navigateBack()
            })
            
            
            
            NewBTTextField(value: $email,
                           placeholder: "email or username",
                           keyboardType: .emailAddress,
                           contentType: .emailAddress)
            
            NewBTSecureField(value: $password, placeholder: "password")
            
            ActionButtons(title: "Login",
                          height: 8,
                          disabled: loginDisabled,
                          action: onLoginWithEmailAndPassword)
            
            
            Button("Forgot password".uppercased()) {
                onForgotPasscode()
            }
            .foregroundStyle(Color.blueGradient)
            .modifier(CustomText(size: 20, font: .semiBold))
            
            
            Spacer()
            
            Group {
                ProviderLoginButton(provider: .apple,
                                    backgroundColor: .BTBackground,
                                    strokeColor: .BTStroke,
                                    strokeSize: 2,
                                    action: onLoginWithApple)
                
                ProviderLoginButton(provider: .google,
                                    backgroundColor: .BTBackground,
                                    strokeColor: .BTStroke,
                                    strokeSize: 2,
                                    action: onLoginWithGoogle)
            }
            
            Text("By signing in to BibleTrivia, you agree to our Terms and Privacy Policy.")
                .modifier(CustomText(size: 12, font: .regular))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard)
        .padding(.horizontal, Constants.hPadding)
        .padding(.vertical, 30)
        .background(Color.BTBackground)
        .onChange(of: email) {
            loginDisabled = email.isEmpty && password.isEmpty
        }
        .onTapGesture {
            dismissKeyboard()
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}

