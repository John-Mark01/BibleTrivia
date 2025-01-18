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
    @ObservedObject var router = Router()
    @State private var quizStore = QuizStore(supabase: Supabase())
    @State private var signInStatus: SignInStatus = .idle
    let userManager = UserManager()
    let streakManager = StreakManager()
    let userDefaults = UserDefaults.standard
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                RouterView {
                    Group {
                        switch signInStatus {
                        case .idle:
                            ProgressView("Loading...")
                        case .signedIn:
                            HomeViewTabBar()
                        case .notSignedIn:
                            WelcomeView()
                        }
                    }
                }
            }
            .environment(quizStore)
            .environment(userManager)
            .environment(\.userName, "John-Mark")
            .environmentObject(router)
            .tint(Color.BTBlack)
            .overlay {
                if LoadingManager.shared.isShowing {
                    LoadingView()
                }
                if quizStore.showAlert {
                    AlertDialog(isPresented: $quizStore.showAlert, title: quizStore.alertTitle, message: quizStore.alertMessage, buttonTitle: quizStore.alertButtonTitle, primaryAction: { router.navigateToRoot() })
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
                    let
                    _ = try await userManager.supabase.auth.session
                    // streaks managing
                    await userManager.downloadUserData()
                    // get initial data
                    try await quizStore.loadInitialData()
                    signInStatus = .signedIn
                } catch let error as AuthError {
                    print (error)
                    signInStatus = .notSignedIn
                } catch {
                    print(error.localizedDescription)
                    signInStatus = .notSignedIn
                }
            } else if case .signedIn = event {
                await userManager.downloadUserData()
                signInStatus = .signedIn
            }  else if case .signedOut = event {
                signInStatus = .notSignedIn
                router.navigateToRoot()
            }
        }
    }
    
    private enum SignInStatus {
        case idle
        case signedIn
        case notSignedIn
    }
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
