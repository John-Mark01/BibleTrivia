//
//  LetsStartAQuizScreen 2.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 20.04.25.
//


import SwiftUI

struct LetsCreateYourProfileScreen: View {
    @Environment(OnboardingManager.self) private var onboardingManager
    @Environment(QuizStore.self) private var quizStore
    @Environment(Router.self) private var router
    
    var message: String = "Let's create your profile!"
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(message)
                .applyFont(.semiBold, size: 40)
            
            Spacer()
            
            OnboardButton(text: "Continue", action: onContinue)
        }
        .applyBackground()
        .applyViewPaddings()
        .navigationBarBackButtonHidden()
    }
    
    func onContinue() {
        //TODO: router.navigate(to: .onboardUserDetails)
    }
}

#Preview {
    let manager = OnboardingManager(supabase: Supabase())
    NavigationStack {
        LetsCreateYourProfileScreen(message: "This is a test message!")
    }
    .environment(manager)
    .environment(Router.shared)
    .environment(QuizStore(supabase: Supabase()))
    .environment(OnboardingManager(supabase: Supabase()))
}
