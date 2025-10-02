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
    @State private var onboardingManager: OnboardingManager
    
    @State private var signInStatus: SignInStatus = .idle
    
    init() {
        // Initialize all @State properties that depend on supabaseClient
        let supabaseClient = SupabaseClient(
            supabaseURL: Secrets.supabaseURL,
            supabaseKey: Secrets.supabaseAPIKey
        )
        
        _supabaseClient = State(initialValue: supabaseClient)
        _quizStore = State(initialValue: QuizStore(supabase: Supabase(supabaseClient: supabaseClient)))
        _userManager = State(initialValue: UserManager(supabase: Supabase(supabaseClient: supabaseClient), alertManager: .shared))
        _onboardingManager = State(initialValue: OnboardingManager(supabase: Supabase(supabaseClient: supabaseClient)))
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
        .environment(alertManager)
        .environment(onboardingManager)
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
