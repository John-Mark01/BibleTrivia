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
    
    // Sensor Feedback Variables
    @State private var nextButtonTapped: Bool = false
    
    var body: some View {
        ZStack {
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
                            
                            Button(action: {
                                nextButtonTapped.toggle()
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
                            }) {
                                Image("Arrow")
                                    .tint(Color.white)
                            }
                            .frame(width: 67, height: 60)
                            .buttonStyle(NextButton())
                            .sensoryFeedback(.impact, trigger: nextButtonTapped)
                        }
                    }
                    
                }
                .background(Color.BTBackground)
            }
            .navigationBarBackButtonHidden()
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, Constants.verticalPadding)
            .background(Color.BTBackground)
            .blur(radius: alertIsPresented || finishQuizModal ? 3 : 0)
            .disabled(alertIsPresented || finishQuizModal)
            
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

struct ReviewButtonControlls: View {
    
    var onCheckQuestionLeft: () -> Void
    var onCheckQuestionRight: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Button(action: {
                onCheckQuestionLeft()
            }) {
                Image("Arrow")
                    .tint(Color.white)
                    .rotationEffect(.degrees(180))
            }
            .frame(width: 67, height: 60)
            .buttonStyle(NextButton())
            
            Spacer()
            
            Button(action: {
                onCheckQuestionRight()
            }) {
                Image("Arrow")
                    .tint(Color.white)
            }
            .frame(width: 67, height: 60)
            .buttonStyle(NextButton())
        }
    }
}
