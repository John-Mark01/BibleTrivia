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
    @Environment(AuthManager.self) var authManager
    
    @State private var welcomeText: String = "Welcome to BibleTrivia!"
    @State private var firstName: String = "Alya"
    @State private var lastName: String = "Bao Bao"
    @State private var age: String = "22"
    @State private var email: String = "alya@baobao.com"
    @State private var password: String = "password"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            HStack {
                Spacer()
                Text(welcomeText)
                    .modifier(CustomText(size: 22, font: .semiBold))
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Enter our first name")
                    .modifier(CustomText(size: 14, font: .medium))
                
                TextField("First Name", text: $firstName)
                    .padding()
                    .background(Color.BTLightGray)
                    .cornerRadius(16)
                    .overlay(content: { RoundedRectangle(cornerRadius: 14).stroke(Color.BTDarkGray, lineWidth: 2) })
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Enter our last name")
                    .modifier(CustomText(size: 14, font: .medium))
                
                TextField("Last Name", text: $lastName)
                    .padding()
                    .background(Color.BTLightGray)
                    .cornerRadius(16)
                    .overlay(content: { RoundedRectangle(cornerRadius: 14).stroke(Color.BTDarkGray, lineWidth: 2) })
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Enter your age")
                    .modifier(CustomText(size: 14, font: .medium))
                
                TextField("Age", text: $age)
                    .padding()
                    .background(Color.BTLightGray)
                    .cornerRadius(16)
                    .keyboardType(.numberPad)
                    .overlay(content: { RoundedRectangle(cornerRadius: 14).stroke(Color.BTDarkGray, lineWidth: 2) })
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
                        do {
                            try await authManager.signUp(email: email, password: password, firstName: firstName, lastName: lastName, age: age)
                            welcomeText = "Signup successful!"
                        } catch {
                            welcomeText = "Error signing up - \(error.localizedDescription)"
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
    let quizStore = QuizStore(supabase: Supabase())
    let auth = AuthManager()
    NavigationStack {
        SignUpScreen()
    }
    .environment(quizStore)
    .environment(auth)
    .environmentObject(Router())
}
struct BTTextField: View {
    @State var text: String = ""
    
    var isSecure: Bool = false
    @State private var offset: CGFloat = 35
    @State private var isTapped: Bool = false
    
    var body: some View {
            
            if isSecure {
                SecureField("", text: $text)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("Password")
                        .modifier(CustomText(size: 18, font: .regular))
                        .padding()
                        .offset(y: offset)
                    
                    TextField("", text: $text)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .frame(height: 48)
                                .foregroundStyle(Color.BTStroke)
                        )
                }
                .onTapGesture {
                    withAnimation {
                        self.offset = -5
                    }
                }
            }
        }
}

#Preview("Text Field") {
    BTTextField()
        .padding()
}
