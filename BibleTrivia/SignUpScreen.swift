//
//  SignUpScreen.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 22.12.24.
//

import SwiftUI

struct SignUpScreen: View {
    @EnvironmentObject var router: Router
    @Environment(QuizStore.self) var quizStore
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            HStack {
                Spacer()
                Text("Welcome to BibleTrivia!")
                    .modifier(CustomText(size: 22, font: .semiBold))
                Spacer()
            }

            
            VStack(alignment: .leading, spacing: 4) {
                Text("Enter your e-mail")
                    .modifier(CustomText(size: 14, font: .medium))
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.BTLightGray)
                    .cornerRadius(16)
                    .overlay(content: { RoundedRectangle(cornerRadius: 14).stroke(Color.BTDarkGray, lineWidth: 2) })
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Enter your password")
                    .modifier(CustomText(size: 14, font: .medium))
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.BTLightGray)
                    .cornerRadius(16)
                    .overlay(content: { RoundedRectangle(cornerRadius: 14).stroke(Color.BTDarkGray, lineWidth: 2) })
            }
            
            Spacer()
            
            VStack(alignment: .center) {
                ActionButtons(title: "Sign Up", action: {
                    Task {
                        try await quizStore.supabase.signIn(email: email, password: password) { succsess in
                            router.navigateToRoot()
                        }
                    }
                })
            }
            .padding(.top, 40)
            
            
            Spacer()
        }
        .background(Color.BTBackground)
        .padding(.horizontal, Constants.hPadding)
        .padding(.vertical, 32)
        .navigationTitle("Sign Up")
    }
}

#Preview {
    NavigationStack {
        SignUpScreen()
    }
}
