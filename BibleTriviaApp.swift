//
//  BibleTriviaApp.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI
import Auth

@main
struct BibleTriviaApp: App {
    @State private var router = Router.shared
    @State private var quizStore = QuizStore(supabase: Supabase())
    @State private var signInStatus: SignInStatus = .idle
    @State private var alertManager = AlertManager.shared
    let onboardingManager = OnboardingManager(supabase: Supabase())
    let userManager = UserManager()
    let streakManager = StreakManager()
    let userDefaults = UserDefaults.standard
    
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
                //TODO: Move quizStore error handling into AlertManager
                if quizStore.showAlert {
                    AlertDialog(isPresented: $quizStore.showAlert, title: quizStore.alertTitle, message: quizStore.alertMessage, buttonTitle: quizStore.alertButtonTitle, primaryAction: { router.popToRoot() })
                }
                
                if alertManager.show {
                    AlertDialog(isPresented: $alertManager.show, title: alertManager.alertTitle, message: alertManager.alertMessage, buttonTitle: alertManager.buttonText, primaryAction: alertManager.primaryAction ?? {})
                }
            }
            .task {
                do {
                    try await listenAuthEvents()
                } catch {
                    quizStore.showAlert(message: "Your session expired. Please sign in again", buttonTitle: "Okay")
                }
            }
        }
    }
    
    private func listenAuthEvents() async throws {
        
        for await (event, _) in userManager.supabase.auth.authStateChanges {
            if case .initialSession = event {
                do {
                    let _ = try await userManager.supabase.auth.session
                    // streaks managing
                    await userManager.downloadUserData()
                    await userManager.checkInUser()
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
                await userManager.downloadUserData()
                await userManager.checkInUser()
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
