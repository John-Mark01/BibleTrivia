//
//  BibleTriviaApp.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

@main
struct BibleTriviaApp: App {
    var body: some Scene {
        @ObservedObject var router = Router()
        WindowGroup {
            NavigationStack(path: $router.path) {
                RouterView {
                    SplashScreen()
                }
            }
            .environment(QuizStore())
            .environmentObject(router)
            .tint(Color.BTBlack)
        }
    }
}
