//
//  BibleTriviaApp.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI
import Supabase
import Auth

@main
struct BibleTriviaApp: App {
    @State private var router = Router.shared
    @State private var supabaseClient = SupabaseClient(supabaseURL: Secrets.supabaseURL, supabaseKey: Secrets.supabaseAPIKey)
    @State private var supabase = Supabase()
    
    
    @State private var quizStore = QuizStore(supabase: Supabase())
    @State private var userManager: UserManager = UserManager(supabase: Supabase(), alertManager: .shared)
    
    @State private var alertManager = AlertManager.shared
    let onboardingManager = OnboardingManager(supabase: Supabase())
    
    @State private var signInStatus: SignInStatus = .idle
    
    var body: some Scene {
        WindowGroup {
            RouterView {
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
            }
            .environment(quizStore)
            .environment(userManager)
            .environment(alertManager)
            .environment(onboardingManager)
            .environment(\.userName, "John-Mark")
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
                    alertManager.showAlert(type: .error, message: "Your session expired. Please sign in again", buttonText: "Okay", action: {})
                }
            }
        }
    }
    
    private func listenAuthEvents() async throws {
        
        for await (event, _) in userManager.supabase.auth.authStateChanges {
            let userID = try? await userManager.supabase.auth.session.user.id
            
            if case .initialSession = event {
                do {
                    let _ = try await userManager.supabase.auth.session
                    // streaks managing
                    await userManager.fetchUserAndDownloadInitialData(userID: userID ?? .init())
                    // get initial data
                    try await quizStore.loadInitialData()
                    setSignedInStatus()
                } catch let error as AuthError {
                    print (error)
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
    
    private enum SignInStatus {
        case idle
        case signedIn
        case notSignedIn
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
}
