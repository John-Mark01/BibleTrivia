//
//  RouterView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 9.10.24.
//

import SwiftUI
import Supabase

/// App Composition Root.
/// Here are all the business logic objects created
/// - UserStore, QuizStore, AlertManager, Router, OnboardingManager, Auth,

@MainActor
struct RouterView: View {
    @State private var router = Router.shared
    @State private var alertManager = AlertManager.shared
    
    @State private var supabaseClient: SupabaseClient
    @State private var quizStore: QuizStore
    @State private var userStore: UserStore
    @State private var authManager: AuthManager
//    @State private var onboardingManager: OnboardingManager
    
    @State private var signInStatus: SignInStatus = .idle
    
    init() {
        // Initialize all @State properties that depend on supabaseClient
        let supabaseClient = SupabaseClient(
            supabaseURL: Secrets.supabaseURL,
            supabaseKey: Secrets.supabaseAPIKey
        )
        
        _supabaseClient = State(initialValue: supabaseClient)
        _quizStore = State(initialValue: QuizStore(supabase: Supabase(supabaseClient: supabaseClient)))
        _userStore = State(initialValue: UserStore(supabase: Supabase(supabaseClient: supabaseClient), alertManager: .shared)) //TODO: Remove AlertManager dependency
        _authManager = State(initialValue: AuthManager(supabaseClient: supabaseClient))
//        _onboardingManager = State(initialValue: OnboardingManager(supabase: Supabase(supabaseClient: supabaseClient)))
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                switch signInStatus {
                case .idle:
                    LoadingView()
                case .signedIn:
                    BTTabBar()
                case .notSignedIn:
                    WelcomeView()
                }
            }
            .navigationDestination(for: Router.Destination.self) { destination in
                router.view(for: destination)
            }
        }
        .applyAlertHandling()
        .tint(Color.BTBlack)
        .environment(quizStore)
        .environment(userStore)
        .environment(authManager)
        .environment(alertManager)
//        .environment(onboardingManager)
        .environment(router)
        .overlay {
            if LoadingManager.shared.isShowing {
                LoadingView()
            }
        }
        .task {
            do {
                try await listenAuthEvents()
            } catch {
                alertManager.showAlert(
                    type: .error,
                    message: "Your session expired. Please sign in again",
                    buttonText: "Okay",
                    action: {}
                )
                await setNotSignedInStatus()
            }
        }
        .onOpenURL { url in
            handleAuthDeepLink(url)
        }
    }
    
    @MainActor
    private func listenAuthEvents() async throws {
        for await (event, _) in supabaseClient.auth.authStateChanges {
            let userID = try? await supabaseClient.auth.session.user.id
            UserDefaults.standard.set(userID?.uuidString, forKey: "userID")
            
            if case .initialSession = event {
                do {
                    let _ = try await supabaseClient.auth.session
                    await userStore.fetchUserAndDownloadInitialData(userID: userID ?? .init())
                    try await quizStore.loadInitialData()
                    await setSignedInStatus()
                    
                } catch {
                    print("🔴 listenAuthEvents — \(error.localizedDescription)\n")
                    await setNotSignedInStatus()
                }
            } else if case .signedIn = event {
                await userStore.fetchUserAndDownloadInitialData(userID: userID ?? .init())
                try await quizStore.loadInitialData()
                await setSignedInStatus()
                
            } else if case .signedOut = event {
                await setNotSignedInStatus()
            }
        }
    }
    
    private func handleAuthDeepLink(_ url: URL) {
        Task {
            guard url.scheme == "bibletrivia", url.host == "auth" else { return }
            
            // Email confirmation callback with OTP code
            if url.path == "/callback" {
                // Extract the token_hash or code from URL
                guard let code = url.queryParameters?["token_hash"] ?? url.queryParameters?["code"] else {
                    print("❌ No verification code found in URL")
                    return
                }
                
                print("✅ Received verification code from email link")
                
                // Get email from stored value (you'll need to store this during sign up)
                guard let email = UserDefaults.standard.string(forKey: "pendingVerificationEmail") else {
                    await MainActor.run {
                        alertManager.showAlert(
                            type: .error,
                            message: "Session expired. Please sign up again.",
                            buttonText: "OK",
                            action: { router.popToRoot() }
                        )
                    }
                    return
                }
                
                // Verify the OTP code
                await authManager.verifyEmailWithCode(email: email, code: code) {
                    router.popToRoot()
                }
            }
            
            // Password reset callback
            if url.path == "/reset-password" {
                // Navigate to password reset view
                await MainActor.run {
                    router.navigateTo(.resetPassword)
                }
            }
        }
    }
    
    private func setSignedInStatus() async {
        await MainActor.run {
            withAnimation {
                signInStatus = .signedIn
                router.popToRoot()
            }
        }
    }
    
    private func setNotSignedInStatus() async {
       await MainActor.run {
            withAnimation {
                signInStatus = .notSignedIn
                router.popToRoot()
            }
        }
    }
    
    private enum SignInStatus {
        case idle
        case signedIn
        case notSignedIn
    }
}
