//
//  AuthManager.swift
//  BibleTrivia
//

import Foundation
import Supabase

/// Owns authentication state and every auth flow (sign up, sign in, email
/// verification, password reset, sign out, account deletion).
@MainActor
@Observable
final class AuthManager {

    enum State: Equatable {
        /// Still restoring the stored session at launch.
        case unknown
        case signedOut
        case signedIn(userId: UUID)
    }

    private(set) var state: State = .unknown
    /// True while the user arrived from a password-reset link and must choose a new password.
    var isResettingPassword = false

    private let client: SupabaseClient
    private let api: BibleTriviaAPI
    private let alerts: AlertManager
    private let loading: LoadingManager

    init(client: SupabaseClient, api: BibleTriviaAPI, alerts: AlertManager, loading: LoadingManager) {
        self.client = client
        self.api = api
        self.alerts = alerts
        self.loading = loading
    }

    // MARK: Session

    /// Runs for the app's lifetime and mirrors Supabase auth events into `state`.
    func observeAuthChanges() async {
        for await (event, session) in client.auth.authStateChanges {
            switch event {
            case .initialSession:
                await restore(session)
            case .signedIn, .tokenRefreshed, .userUpdated:
                if let session { setSignedIn(session.user.id) }
            case .passwordRecovery:
                if let session { setSignedIn(session.user.id) }
                isResettingPassword = true
            case .signedOut, .userDeleted:
                state = .signedOut
                isResettingPassword = false
            default:
                break
            }
        }
    }

    private func restore(_ session: Session?) async {
        guard session != nil else {
            state = .signedOut
            return
        }
        do {
            // Refreshes the stored session if it has expired.
            let current = try await client.auth.session
            setSignedIn(current.user.id)
        } catch {
            state = .signedOut
            alerts.showAlert(type: .information, message: "Your session expired. Please sign in again.")
        }
    }

    private func setSignedIn(_ userId: UUID) {
        if state != .signedIn(userId: userId) {
            state = .signedIn(userId: userId)
        }
    }

    // MARK: Sign up / sign in

    /// Returns true when the account was created and a confirmation email sent.
    func signUp(email: String, password: String, firstName: String, lastName: String, age: Int) async -> Bool {
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        do {
            _ = try await loading.perform {
                try await client.auth.signUp(
                    email: email,
                    password: password,
                    data: [
                        "first_name": .string(firstName),
                        "last_name": .string(lastName),
                        "user_name": .string(fullName),
                        "age": .integer(age),
                    ],
                    redirectTo: AppConfig.authCallbackURL
                )
            }
            return true
        } catch {
            alerts.show(error)
            return false
        }
    }

    func signIn(email: String, password: String) async {
        do {
            try await loading.perform {
                _ = try await client.auth.signIn(email: email, password: password)
            }
            // `observeAuthChanges` moves the app to the signed-in state.
        } catch {
            if let authError = error as? AuthError, authError.errorCode == .emailNotConfirmed {
                alerts.showAlert(
                    type: .warning,
                    message: "Please confirm your email before signing in. Check your inbox!",
                    buttonText: "Resend Email"
                ) { [weak self] in
                    Task { await self?.resendConfirmationEmail(email: email) }
                }
            } else {
                alerts.show(error)
            }
        }
    }

    // MARK: Email verification

    func verifyEmail(email: String, code: String) async {
        do {
            try await loading.perform {
                _ = try await client.auth.verifyOTP(email: email, token: code, type: .signup)
            }
        } catch {
            alerts.show(error)
        }
    }

    func resendConfirmationEmail(email: String) async {
        do {
            try await loading.perform {
                try await client.auth.resend(email: email, type: .signup, emailRedirectTo: AppConfig.authCallbackURL)
            }
            alerts.showAlert(type: .success, message: "Confirmation email sent! Check your inbox.")
        } catch {
            alerts.show(error)
        }
    }

    // MARK: Deep links

    func handleDeepLink(_ url: URL) async {
        guard AppConfig.isAuthDeepLink(url) else { return }
        let isPasswordReset = url.path() == AppConfig.passwordResetURL.path()

        do {
            try await loading.perform {
                if let tokenHash = url.queryParameters?["token_hash"] {
                    let type = url.queryParameters?["type"].flatMap(EmailOTPType.init(rawValue:))
                        ?? (isPasswordReset ? .recovery : .signup)
                    _ = try await client.auth.verifyOTP(tokenHash: tokenHash, type: type)
                } else {
                    _ = try await client.auth.session(from: url)
                }
            }
            if isPasswordReset {
                isResettingPassword = true
            } else {
                alerts.showAlert(type: .success, message: "Email confirmed! Welcome to BibleTrivia! 🙏", buttonText: "Get Started")
            }
        } catch {
            alerts.show(error)
        }
    }

    // MARK: Password

    /// Returns true when the reset email was sent.
    func sendPasswordResetEmail(email: String) async -> Bool {
        do {
            try await loading.perform {
                try await client.auth.resetPasswordForEmail(email, redirectTo: AppConfig.passwordResetURL)
            }
            alerts.showAlert(type: .success, message: "Password reset email sent! Check your inbox.")
            return true
        } catch {
            alerts.show(error)
            return false
        }
    }

    func updatePassword(_ newPassword: String) async {
        do {
            try await loading.perform {
                _ = try await client.auth.update(user: UserAttributes(password: newPassword))
            }
            isResettingPassword = false
            alerts.showAlert(type: .success, message: "Password updated successfully!")
        } catch {
            alerts.show(error)
        }
    }

    // MARK: Sign out / delete

    func signOut() async {
        do {
            try await loading.perform { try await client.auth.signOut() }
        } catch {
            // Even if the server call fails, clear the local session so the user isn't stuck.
            try? await client.auth.signOut(scope: .local)
        }
    }

    func deleteAccount() async {
        do {
            try await loading.perform { try await api.deleteAccount() }
            try? await client.auth.signOut(scope: .local)
            alerts.showAlert(type: .information, message: "Your account and all your data have been deleted.")
        } catch {
            alerts.show(error)
        }
    }
}
