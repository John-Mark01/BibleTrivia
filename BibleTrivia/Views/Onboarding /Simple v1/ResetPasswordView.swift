//
//  ResetPasswordView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 3.10.25.
//

import SwiftUI

struct ResetPasswordView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(Router.self) private var router
    
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Password")
                .font(.title)
                .bold()
            
            Text("Enter your new password")
                .foregroundStyle(.secondary)
            
            SecureField("New Password", text: $newPassword)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)
            
            if !newPassword.isEmpty && !confirmPassword.isEmpty {
                if newPassword != confirmPassword {
                    Text("Passwords don't match")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
            
            Button("Update Password") {
                guard newPassword == confirmPassword else { return }
                
                Task {
                    await authManager.updatePassword(newPassword: newPassword) {
                        // Navigate to login
                        router.popToRoot()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(newPassword.isEmpty || newPassword != confirmPassword)
            
            Spacer()
        }
        .padding()
    }
}
