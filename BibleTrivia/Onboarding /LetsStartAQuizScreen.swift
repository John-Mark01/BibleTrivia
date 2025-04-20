//
//  OnboardScreenWithMessage.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 2.03.25.
//

import SwiftUI

struct LetsStartAQuizScreen: View {
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
                try await quizStore.loadOnboardingFirstQuiz(topicID: onboardingManager.newUserChosenTopicID)
                
                router.navigateTo(.quizView, from: .onboarding)
            } catch let error as Errors.BTError {
                print("Error in QuizStore.loadOnboardingFirstQuiz:\n\(error)")
            }
        }
    }
}

#Preview {
    let manager = OnboardingManager(supabase: Supabase())
    NavigationStack {
        LetsStartAQuizScreen()
    }
    .environment(manager)
    .environment(Router.shared)
    .environment(QuizStore(supabase: Supabase()))
    .environment(OnboardingManager(supabase: Supabase()))
}
