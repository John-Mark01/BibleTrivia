//
//  LoginView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 3.10.25.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(Router.self) private var router
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome Back")
                .font(.largeTitle)
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .textFieldStyle(.roundedBorder)
            
            Button("Sign In") {
                Task {
                    await authManager.signIn(
                        email: email,
                        password: password
                    ) {
                        // Success - navigate to home
                        router.navigateTo(.home)
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Forgot Password?") {
                router.navigateTo(.forgotPassword)
            }
            .foregroundStyle(.blue)
            
            Divider()
                .padding()
            
            Button("Don't have an account? Sign Up") {
                router.navigateTo(.registration)
            }
        }
        .padding()
    }
}
