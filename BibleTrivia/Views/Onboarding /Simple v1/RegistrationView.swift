//
//  RegistrationView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 3.10.25.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(Router.self) private var router
    
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
            
            TextField("First Name", text: $firstName)
                .textFieldStyle(.roundedBorder)
            
            TextField("Last Name", text: $lastName)
                .textFieldStyle(.roundedBorder)
            
            TextField("Age", text: $age)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $password)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)
            
            Button("Sign Up") {
                Task {
                    await authManager.signUpWithEmailConfirmation(
                        email: email,
                        password: password,
                        firstName: firstName,
                        lastName: lastName,
                        age: age
                    ) {
                        // Navigate to email verification pending view
                        router.navigateTo(.emailVerificationPending(email: email))
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Already have an account? Sign In") {
                router.navigateTo(.login)
            }
        }
        .padding()
    }
}
