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
    
    @State private var finishQuizModal: Bool = false
    @State private var alertIsPresented: Bool = false
    @State private var isActionFromQuizStore: Bool = false
    
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
                // Normal Alert
                if alertIsPresented {
                    AlertDialog(isPresented: $alertIsPresented, title: quizStore.alertTitle, message: quizStore.alertMessage, buttonTitle: quizStore.alertButtonTitle, primaryAction: { router.popToRoot() }, isAnotherAction: isActionFromQuizStore)
                }
            }
            .zIndex(999)
            
            VStack(alignment: .leading, spacing: 10) {
                
                // ProgressView + Close
                HStack(spacing: 16) {
                    LinearProgressView(progress: Int(quizStore.calculateCurrentQuestionProgress()), goal: quizStore.currentQuiz.numberOfQuestions)
                    
                    Spacer()
                    
                    Button(action: {
                        isActionFromQuizStore = false
                        alertIsPresented = true
                        quizStore.alertTitle = "Quit Quiz?"
                        quizStore.alertMessage = "Do want to quit \(quizStore.currentQuiz.name)?\nYou can still finish your quiz later."
                        quizStore.alertButtonTitle = "Close Quiz"
                    }) {
                        Image("Close")
                    }
                    .sensoryFeedback(.error, trigger: alertIsPresented)
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
                                quizStore.answerQuestion() { quizFinished in
                                    withAnimation {
                                        if !quizFinished {
                                            quizStore.toNextQuestion()
                                        } else {
                                            self.finishQuizModal = true
                                        }
                                    }
                                } error: { error in
                                    withAnimation {
                                        isActionFromQuizStore = true
                                        alertIsPresented = error
                                    }
                                }
                            }
                            .buttonStyle(.next(width: 67, direction: .right))
                        }
                    }
                    
                }
            }
            .navigationBarBackButtonHidden()
            .blur(radius: alertIsPresented || finishQuizModal ? 3 : 0)
            .disabled(alertIsPresented || finishQuizModal)
            .applyViewPaddings()
            .applyBackground()
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
                quizStore.checkAnswerToTheLeft { error in
                    withAnimation {
                        isActionFromQuizStore = true
                        alertIsPresented = error
                    }
                }
            }
        }
    }
    
   private func goRightCheckingQuesiton() {
        if quizStore.currentQuiz.isInReview {
            withAnimation {
                quizStore.checkAnswerToTheRight {
                    finishQuizModal = true
                }
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
    .environment(AlertManager())
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
