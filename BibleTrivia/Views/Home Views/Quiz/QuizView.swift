//
//  QuizView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 13.10.24.
//

import SwiftUI

struct QuizView: View {
    @Environment(QuizStore.self) private var quizStore
    @Environment(Router.self) private var router
    @Environment(AlertManager.self) private var alertManager
    
    @State private var finishQuizModal: Bool = false
    
    var body: some View {
        ZStack {
            Group {
                if finishQuizModal {
                    FinishedQuizModal(isPresented: $finishQuizModal, quiz: quizStore.currentQuiz, onFinishQuiz: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateAfterFinish()
                        }
                    }, onReviewQuiz: {
                        quizStore.enterQuizReviewMode()
                    })
                }
//                // Normal Alert
//                if alertIsPresented {
//                    AlertDialog(isPresented: $alertIsPresented, title: quizStore.alertTitle, message: quizStore.alertMessage, buttonTitle: quizStore.alertButtonTitle, primaryAction: { router.popToRoot() }, isAnotherAction: isActionFromQuizStore)
//                }
            }
            .zIndex(999)
            
            VStack(alignment: .leading, spacing: 10) {
                
                // ProgressView + Close
                HStack(spacing: 16) {
                    LinearProgressView(progress: Int(quizStore.calculateCurrentQuestionProgress()), goal: quizStore.currentQuiz.numberOfQuestions)
                    
                    Spacer()
                    
                    Image("Close")
                        .makeButton(
                            action: {
                                alertManager.showQuizExitAlert(quizName: quizStore.currentQuiz.name) {
                                    router.popBackStack()
                                }
                            },
                            addHapticFeedback: true,
                            feedbackStyle: .error
                        )
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Question" + " \((quizStore.currentQuiz.currentQuestionIndex) + 1)")
                        .applyFont(.semiBold, size: 14)
                    
                    Text((quizStore.currentQuiz.questions[quizStore.currentQuiz.currentQuestionIndex].text) + "?")
                        .applyFont(.semiBold, size: 20)
                    
                    
                    QuizViewAnswerList()
                        .padding(.top, 16)
                    
                    
                    if quizStore.currentQuiz.isInReview {
                        HStack {
                            Spacer()
                            Text(quizStore.currentQuiz.currentQuestion.userAnswerIsCorrect ? "Correct!" : "Incorrect...")
                                .applyFont(.medium, size: 20)
                            
                            Spacer()
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    if quizStore.currentQuiz.isInReview {
                        
                        ReviewButtonControlls(
                            onCheckQuestionLeft: goLeftCheckingQuesiton,
                            onCheckQuestionRight: goRightCheckingQuesiton
                        )
                        
                    } else {
                        HStack(alignment: .center, spacing: 20) {
                            Spacer()
                            
                            Text("NEXT")
                                .applyFont(.regular, size: 14, textColor: .BTPrimary)
                            
                            Button("") {
                               let result = quizStore.answerQuestion()
                                switch result {
                                case .moveToNext:
                                    quizStore.toNextQuestion()
                                case .quizCompleted:
                                    self.finishQuizModal = true
                                case .error:
                                    break
                                }
                            }
                            .buttonStyle(.next(width: 67, direction: .right))
                        }
                    }
                    
                }
            }
            .navigationBarBackButtonHidden()
            .blur(radius: finishQuizModal ? 3 : 0)
            .disabled(finishQuizModal)
            .applyViewPaddings()
            .applyBackground()
            .applyAlertHandling()
        }
    }
    
   private func navigateAfterFinish() {
       let context = router.getCurrentContext()
       
       if context == .onboarding {
            router.navigateTo(.streakView, from: .onboarding)
        } else {
            router.popToRoot()
        }
    }
    
   private func goLeftCheckingQuesiton() {
        withAnimation {
            if quizStore.currentQuiz.isInReview {
                let _ = quizStore.checkAnswerToTheLeft()
            }
        }
    }
    
   private func goRightCheckingQuesiton() {
        if quizStore.currentQuiz.isInReview {
            withAnimation {
                let _ = quizStore.checkAnswerToTheRight()
            }
        }
    }
}

#Preview {
    RouterView {
        QuizView()
    }
    .environment(Router.shared)
    .environment(QuizStore(repository: QuizRepository(supabase: Supabase()), manager: .init()))
    .environment(AlertManager.shared)
}

struct ReviewButtonControlls: View {
    
    var onCheckQuestionLeft: () -> Void
    var onCheckQuestionRight: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Button("") {
                onCheckQuestionLeft()
            }
            .buttonStyle(.next(width: 67, direction: .left))
            
            Spacer()
            
            Button("") {
                onCheckQuestionRight()
            }
            .buttonStyle(.next(width: 67, direction: .right))
        }
    }
}
