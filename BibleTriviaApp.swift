//
//  BibleTriviaApp.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

@main
struct BibleTriviaApp: App {
    @ObservedObject var router = Router()
    @State private var quizStore = QuizStore(supabase: Supabase())
    var body: some Scene {
        
        WindowGroup {
            NavigationStack(path: $router.path) {
                RouterView {
                    SplashScreen()
                }
            }
            .environment(quizStore)
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
        }
    }
}
