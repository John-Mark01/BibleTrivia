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
/// - UserStore, QuizStore, TopicStore, AlertManager, Router, OnboardingManager, Auth,

@MainActor
struct RouterView: View {
    @State private var router = Router.shared
    @State private var alertManager = AlertManager.shared
    
    @State private var supabaseClient: SupabaseClient
    @State private var quizStore: QuizStore
    @State private var topicStore: TopicStore
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
        _topicStore = State(initialValue: TopicStore(supabase: Supabase(supabaseClient: supabaseClient)))
        _userStore = State(initialValue: UserStore(supabase: Supabase(supabaseClient: supabaseClient)))
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
        .tint(.btBlack)
        .environment(quizStore)
        .environment(topicStore)
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
        .task { await listenAuthEvents() }
        .onOpenURL { handleAuthDeepLink($0) }
    }
    
    @MainActor
    private func listenAuthEvents() async {
        for await (event, _) in supabaseClient.auth.authStateChanges {
            // Get the authenticated user ID from the session
            guard let userID = try? await supabaseClient.auth.session.user.id else {
                await setNotSignedInStatus()
                continue
            }
            
            userStore.setUserId(userID)
            quizStore.setUserId(userID)
            topicStore.setUserId(userID)
            
            if case .initialSession = event {
                do {
                    let _ = try await supabaseClient.auth.session
                    await userStore.fetchUserAndDownloadInitialData()
                    await quizStore.loadQuizzes()
                    await topicStore.loadTopics()
                    await setSignedInStatus()
                    
                } catch {
                    alertManager.showAlert(
                        type: .information,
                        message: "Your session expired. Please sign in again",
                        buttonText: "Okay",
                        action: {}
                    )
                    await setNotSignedInStatus()
                    print("🔴 listenAuthEvents() error — \(error.localizedDescription)\n")
                }
            } else if case .signedIn = event {
                await userStore.fetchUserAndDownloadInitialData()
                await quizStore.loadQuizzes()
                await topicStore.loadTopics()
                await setSignedInStatus()
                
            } else if case .signedOut = event {
                await setNotSignedInStatus()
            }
        }
    }
    
    private func handleAuthDeepLink(_ url: URL) {
        Task {
            print("handling deep link:\n\(url.absoluteString)")
            guard url.scheme == "bibletrivia", url.host == "auth" else { return }
            
            // Email confirmation callback with OTP code
            if url.path == "/callback" {
                // Extract the token_hash or code from URL
                guard let tokenHash = url.queryParameters?["token_hash"] else {
                    print("❌ No verification code found in URL")
                    return
                }
                
                await authManager.verifyEmailWithTokenHash(tokenHash)
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
