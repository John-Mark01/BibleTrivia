//
//  LoginView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 13.01.25.
//

import SwiftUI

struct SignInScreen: View {
    @EnvironmentObject var router: Router
    @Environment(UserManager.self) var userManager
    
    @State private var email: String = "alya@baobao.com"
    @State private var password: String = "password"
    @State private var welcomeText: String = "Welcome back!"
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(welcomeText)
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
                ActionButtons(title: "Sign In", action: {
                    Task {
                        do {
                            try await userManager.signIn(email: email, password: password) { succsess in
                                if succsess {print("succsess") }
                            }
                            welcomeText = "SignIn successful!"
                        } catch {
                            welcomeText = "Error signing in - \(error.localizedDescription)"
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
        .navigationTitle("Sign In")
    }

}

#Preview {
    NavigationStack {
        SignInScreen()
    }
    .environment(UserManager())
    .environmentObject(Router())
}
