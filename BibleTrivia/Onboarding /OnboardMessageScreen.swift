//
//  OnboardScreenWithMessage.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 2.03.25.
//

import SwiftUI

struct OnboardMessageScreen: View {
    @Environment(OnboardingManager.self) private var onboardingManager
    @Environment(QuizStore.self) private var quizStore
    @Environment(Router.self) private var router
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Let's try a quiz!")
                .addFont(style: .semiBold, size: 40)
            
            Spacer()
            
            OnboardButton(text: "Continue", action: startFirstQuiz)
        }
        .addViewPaddings()
        .addBackground()
        .navigationBarBackButtonHidden()
    }
    
    func startFirstQuiz() {
        Task {
            do {
                try await loadFirstQuiz()
                router.navigateTo(.quizView)
            } catch let error as Errors.BTError {
                print("Error in QuizStore.loadOnboardingFirstQuiz:\n\(error)")
            }
        }
    }
    
    func loadFirstQuiz() async throws {
        try await quizStore.loadOnboardingFirstQuiz(topicID: onboardingManager.newUserChosenTopicID)
    }
}

#Preview {
    let manager = OnboardingManager(supabase: Supabase())
    NavigationStack {
        OnboardMessageScreen()
    }
    .environment(manager)
    .environment(Router.shared)
}
