//
//  LoginView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 18.01.25.
//

//import SwiftUI
//
//struct LoginView: View {
//    @Environment(Router.self) private var router
//    @Environment(AuthManager.self) var authManager
//    
//    @State private var email: String = ""
//    @State private var password: String = ""
//    
//    private var loginDisabled: Bool {
//        email.isEmpty && password.isEmpty
//    }
//    
//    var body: some View {
//
//        VStack(alignment: .center, spacing: 16) {
//            
//            CustomNavigationBar(title: "Enter your details",
//                                leftButtonAction: {
//                print("Navigate back")
//                router.popBackStack()
//            })
//            
//            
//            
//            NewBTTextField(value: $email,
//                           placeholder: "email or username",
//                           keyboardType: .emailAddress,
//                           contentType: .emailAddress)
//            
//            NewBTSecureField(value: $password, placeholder: "password")
//            
//            Button("Login") {
//                onLoginWithEmailAndPassword()
//            }
//            .buttonStyle(.primary)
//            .buttonDisabled(loginDisabled)
//            
//            
//            Button("Forgot password".uppercased()) {
//                onForgotPasscode()
//            }
//            .applyFont(.semiBold, size: 15, textColor: .blueGradient)
//            
//            
//            Spacer()
//            
//            Group {
//                ProviderLoginButton(provider: .apple,
//                                    backgroundColor: .BTBackground,
//                                    strokeColor: .BTStroke,
//                                    strokeSize: 2,
//                                    action: onLoginWithApple)
//                
//                ProviderLoginButton(provider: .google,
//                                    backgroundColor: .BTBackground,
//                                    strokeColor: .BTStroke,
//                                    strokeSize: 2,
//                                    action: onLoginWithGoogle)
//            }
//            
//            Text("By signing in to BibleTrivia, you agree to our Terms and Privacy Policy.")
//                .applyFont(.regular, size: 12)
//                .multilineTextAlignment(.center)
//        }
//        .applyBackground()
//        .applyViewPaddings(.horizontal)
//        .navigationBarBackButtonHidden()
//        .ignoresSafeArea(.keyboard)
//        .padding(.top, 30)
//        .onTapGesture { dismissKeyboard() }
//    }
//    
//    private func onForgotPasscode() {
//        
//    }
//    
//    private func onLoginWithEmailAndPassword() {
//        dismissKeyboard()
//        Task {
//            await authManager.signIn(email: email, password: password) {
//                router.navigateTo(.home)
//            }
//        }
//    }
//    private func onLoginWithApple() { }
//    private func onLoginWithGoogle() { }
//}
//
//#Preview {
//    PreviewEnvironmentView {
//        LoginView()
//    }
//}

