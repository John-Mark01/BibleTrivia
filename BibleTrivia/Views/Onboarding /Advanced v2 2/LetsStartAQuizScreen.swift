//
//  OnboardScreenWithMessage.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 2.03.25.
//
//
//import SwiftUI
//
//struct LetsStartAQuizScreen: View {
//    @Environment(OnboardingManager.self) private var onboardingManager
//    @Environment(QuizStore.self) private var quizStore
//    @Environment(Router.self) private var router
//    
//    var body: some View {
//        VStack {
//            Spacer()
//            
//            Text("Let's try a quiz!")
//                .applyFont(.semiBold, size: 40)
//            
//            Spacer()
//            
//            OnboardButton(text: "Continue", action: startFirstQuiz)
//        }
//        .navigationBarBackButtonHidden()
//        .applyBackground()
//        .applyViewPaddings()
//    }
//    
//    func startFirstQuiz() {
//        Task {
//            do {
//                try await quizStore.loadOnboardingFirstQuiz(topicID: onboardingManager.newUserChosenTopicID)
//                
//                router.navigateTo(.quizView, from: .onboarding)
//            } catch let error as Errors.BTError {
//                print("Error in QuizStore.loadOnboardingFirstQuiz:\n\(error)")
//            }
//        }
//    }
//}
//
//#Preview {
//    PreviewEnvironmentView {
//        LetsStartAQuizScreen()
//    }
//}
