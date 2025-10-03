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
struct RouterView: View {
    @State private var router = Router.shared
    @State private var alertManager = AlertManager.shared
    
    @State private var supabaseClient: SupabaseClient
    @State private var quizStore: QuizStore
    @State private var userManager: UserManager
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
        _userManager = State(initialValue: UserManager(supabase: Supabase(supabaseClient: supabaseClient), alertManager: .shared)) //TODO: Remove AlertManager dependency
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
        .environment(userManager)
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
            }
        }
        .onOpenURL { url in
            handleAuthDeepLink(url)
        }
    }
    
    private func listenAuthEvents() async throws {
        for await (event, _) in supabaseClient.auth.authStateChanges {
            let userID = try? await supabaseClient.auth.session.user.id
            UserDefaults.standard.set(userID?.uuidString, forKey: "userID")
            
            if case .initialSession = event {
                do {
                    let _ = try await supabaseClient.auth.session
                    await userManager.fetchUserAndDownloadInitialData(userID: userID ?? .init())
                    try await quizStore.loadInitialData()
                    setSignedInStatus()
                } catch let error as AuthError {
                    print(error)
                    setNotSignedInStatus()
                } catch {
                    print(error.localizedDescription)
                    setNotSignedInStatus()
                }
            } else if case .signedIn = event {
                await userManager.fetchUserAndDownloadInitialData(userID: userID ?? .init())
                try await quizStore.loadInitialData()
                setSignedInStatus()
            } else if case .signedOut = event {
                setNotSignedInStatus()
                router.popToRoot()
            }
        }
    }
    
    private func handleAuthDeepLink(_ url: URL) {
        Task {
            guard url.scheme == "bibleTrivia" else { return }
            
            // Handle email confirmation: bibleTrivia://auth/callback?token=...
            if url.host == "auth" && url.path == "/callback" {
                if let token = url.queryParameters?["token"] {
                    await authManager.verifyEmail(token: token)
                }
            }
            
            // Handle password reset: bibleTrivia://auth/reset-password?token=...
            if url.host == "auth" && url.path == "/reset-password" {
                if let token = url.queryParameters?["token"] {
                    // Navigate to password reset view
                    router.navigateTo(.resetPassword)
                }
            }
        }
    }
    
    private func setSignedInStatus() {
        withAnimation {
            signInStatus = .signedIn
        }
    }
    
    private func setNotSignedInStatus() {
        withAnimation {
            signInStatus = .notSignedIn
        }
    }
    private enum SignInStatus {
        case idle
        case signedIn
        case notSignedIn
    }
}
