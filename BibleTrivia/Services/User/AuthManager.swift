//
//  AuthManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 5.01.25.
//

import SwiftUI
import Supabase

@Observable class AuthManager {
    
    let supabaseClient: SupabaseClient
    let alertManager: AlertManager
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
        self.alertManager = .shared
    }
    
//MARK: - Sign-Up - (Email Auth)
    
    /// Signs up a new user with email confirmation required
    /// User will receive a confirmation email before they can sign in
    func signUpWithEmailConfirmation(
        email: String,
        password: String,
        firstName: String = "",
        lastName: String = "",
        age: String,
        onSuccess: @escaping () -> Void = {}
    ) async {
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        let userName = "\(firstName) \(lastName)".capitalized
        let userAge = Int(age) ?? 0
        
        do {
            try await supabaseClient.auth.signUp(
                email: email,
                password: password,
                data: [
                    "first_name": .string(firstName),
                    "last_name": .string(lastName),
                    "user_name": .string(userName),
                    "age": .integer(userAge)
                ],
                redirectTo: URL(string: "bibleTrivia://auth/callback")
            )
            
            //TODO: Save user email to Keychain
            UserDefaults.standard.set(email, forKey: "pendingVerificationEmail")
            
            await MainActor.run {
                alertManager.showAlert(
                    type: .success,
                    message: "Account created! Check your email to confirm.",
                    buttonText: "Got it",
                    action: onSuccess
                )
            }
            
        } catch {
            await MainActor.run {
                alertManager.showAlert(
                    type: .error,
                    message: "Sign up failed. Please try again.",
                    buttonText: "Dismiss",
                    action: {}
                )
            }
            print("❌ Sign up error: \(error.localizedDescription)")
        }
    }
    
// MARK: - Sign In - (Email Auth)
    
    /// Standard sign in with email and password
    /// Checks if email is confirmed before allowing access
    func signIn(
        email: String,
        password: String
    ) async {
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        do {
            let response = try await supabaseClient.auth.signIn(
                email: email,
                password: password
            )
            
            // Check if email is confirmed
            guard response.user.emailConfirmedAt != nil else {
                await MainActor.run {
                    alertManager.showAlert(
                        type: .warning,
                        message: "Please confirm your email before signing in. Check your inbox!",
                        buttonText: "Resend Email",
                        action: {
                            Task {
                                await self.resendConfirmationEmail(email: email)
                            }
                        }
                    )
                }
                return
            }
            
            print("✅ User signed in successfully")
        } catch {
            await MainActor.run {
                alertManager.showAlert(
                    type: .error,
                    message: "Sign in failed. Please check your credentials.",
                    buttonText: "Dismiss",
                    action: {}
                )
            }
            print("❌ Sign in error: \(error.localizedDescription)")
        }
    }
    
// MARK: - Email Confirmation - (Email Auth)
    
    func verifyEmailWithCode(email: String, code: String, onSuccess: @escaping () -> Void = {}) async {
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        let supabaseClient = SupabaseClient(
            supabaseURL: Secrets.supabaseURL,
            supabaseKey: Secrets.supabaseAPIKey
        )
        
        do {
            let response = try await supabaseClient.auth.verifyOTP(
                email: email,
                token: code,
                type: .signup
            )
            
            print("✅ Email verified successfully for: \(response.user.email ?? "unknown")")
            
            // Clear the stored email
            UserDefaults.standard.removeObject(forKey: "pendingVerificationEmail")
            onSuccess()
            
        } catch {
            print("❌ Email verification error: \(error.localizedDescription)")
            
            await MainActor.run {
                AlertManager.shared.showAlert(
                    type: .error,
                    message: "Verification failed. The code may have expired.",
                    buttonText: "Dismiss",
                    action: {}
                )
            }
        }
    }
    
    /// Resends the confirmation email to the user
    func resendConfirmationEmail(
        email: String,
        onSuccess: @escaping () -> Void = {}
    ) async {
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        do {
            try await supabaseClient.auth.resend(
                email: email,
                type: .signup,
//                redirectTo: URL(string: "bibleTrivia://auth/callback")
            )
            
            await MainActor.run {
                alertManager.showAlert(
                    type: .success,
                    message: "Confirmation email sent! Check your inbox.",
                    buttonText: "OK",
                    action: onSuccess
                )
            }
            
        } catch {
            await MainActor.run {
                alertManager.showAlert(
                    type: .error,
                    message: "Failed to send email. Please try again later.",
                    buttonText: "Dismiss",
                    action: {}
                )
            }
            print("❌ Resend email error: \(error.localizedDescription)")
        }
    }
    
// MARK: - Password Reset - (Email Auth)
    
    /// Sends a password reset email to the user
    func sendPasswordResetEmail(
        email: String,
        onSuccess: @escaping () -> Void = {}
    ) async {
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        do {
            try await supabaseClient.auth.resetPasswordForEmail(
                email,
                redirectTo: URL(string: "bibleTrivia://auth/reset-password")
            )
            
            await MainActor.run {
                alertManager.showAlert(
                    type: .success,
                    message: "Password reset email sent! Check your inbox.",
                    buttonText: "OK",
                    action: onSuccess
                )
            }
            
        } catch {
            await MainActor.run {
                alertManager.showAlert(
                    type: .error,
                    message: "Failed to send reset email. Please try again.",
                    buttonText: "Dismiss",
                    action: {}
                )
            }
            print("❌ Password reset error: \(error.localizedDescription)")
        }
    }
    
    /// Updates the user's password after they've clicked the reset link
    func updatePassword(
        newPassword: String,
        onSuccess: @escaping () -> Void = {}
    ) async {
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        do {
            try await supabaseClient.auth.update(user: UserAttributes(password: newPassword))
            
            await MainActor.run {
                alertManager.showAlert(
                    type: .success,
                    message: "Password updated successfully!",
                    buttonText: "OK",
                    action: onSuccess
                )
            }
            
        } catch {
            await MainActor.run {
                alertManager.showAlert(
                    type: .error,
                    message: "Failed to update password. Please try again.",
                    buttonText: "Dismiss",
                    action: {}
                )
            }
            print("❌ Password update error: \(error.localizedDescription)")
        }
    }
    
// MARK: - Email Change - (Email Auth)
    
    func changeEmail(
        newEmail: String,
        onSuccess: @escaping () -> Void = {}
    ) async {
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        do {
            try await supabaseClient.auth.update(
                user: UserAttributes(email: newEmail)
            )
            
            await MainActor.run {
                alertManager.showAlert(
                    type: .success,
                    message: "Confirmation email sent to \(newEmail). Please verify your new email.",
                    buttonText: "OK",
                    action: onSuccess
                )
            }
            
        } catch {
            await MainActor.run {
                alertManager.showAlert(
                    type: .error,
                    message: "Failed to change email. Please try again.",
                    buttonText: "Dismiss",
                    action: {}
                )
            }
            print("❌ Email change error: \(error.localizedDescription)")
        }
    }
    
// MARK: - Sign Out - (Auth)
    
    func signOut(onSuccess: @escaping () -> Void = {}) async {
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        do {
            try await supabaseClient.auth.signOut()
            print("✅ User signed out successfully")
            await MainActor.run {
                onSuccess()
            }
        } catch {
            await MainActor.run {
                alertManager.showAlert(
                    type: .error,
                    message: "Couldn't sign out. Please try again.",
                    buttonText: "Dismiss",
                    action: {}
                )
            }
            print("❌ Sign out error: \(error.localizedDescription)")
        }
    }
    
// MARK: - Session Management
    
    func refreshSession(onSuccess: @escaping () -> Void = {}) async {
        do {
            _ = try await supabaseClient.auth.session
            print("✅ Session refreshed successfully")
            await MainActor.run {
                onSuccess()
            }
        } catch {
            print("❌ Session refresh error: \(error.localizedDescription)")
            // Silent fail - don't show alert for session refresh
        }
    }
    
    /// Gets the current authenticated user (returns nil if no session)
    func getCurrentUser() async -> User? {
        do {
            let session = try await supabaseClient.auth.session
            return session.user
        } catch {
            print("❌ No active session")
            return nil
        }
    }
    
    /// Checks if the current user's email is verified
    func isEmailVerified() async -> Bool {
        guard let user = await getCurrentUser() else {
            return false
        }
        return user.emailConfirmedAt != nil
    }
}
