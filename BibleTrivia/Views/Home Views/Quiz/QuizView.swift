//
//  QuizView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 13.10.24.
//

import SwiftUI

struct QuizView: View {
    @Environment(Router.self) private var router
    @Environment(QuizStore.self) private var quizStore
    @Environment(UserManager.self) private var userManager
    @Environment(AlertManager.self) private var alertManager
    
    @State private var finishQuizModal: Bool = false
    
    var body: some View {
        ZStack {
            Group {
                if finishQuizModal {
                    FinishedQuizModal(
                        isPresented: $finishQuizModal,
                        quiz: quizStore.currentQuiz,
                        onFinishQuiz:navigateAfterFinish,
                        onReviewQuiz:quizStore.enterQuizReviewMode
                    )
                }
            }
            .zIndex(999)
            
            VStack(alignment: .leading, spacing: 10) {
                
                // ProgressView + Close
                HStack(spacing: 16) {
                    LinearProgressView(
                        progress: Int(quizStore.calculateCurrentQuestionProgress()),
                        goal: quizStore.currentQuiz.numberOfQuestions
                    )
                    .setStroke(color: .BTDarkGray, size: 1)
                    
                    Image("Close")
                        .makeButton(action: onClose,
                                    addHapticFeedback: true,
                                    feedbackStyle: .error)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Question" + " \((quizStore.currentQuiz.currentQuestionIndex) + 1)")
                        .applyFont(.semiBold, size: 14)
                    
                    Text((quizStore.currentQuiz.questions[quizStore.currentQuiz.currentQuestionIndex].text) + "?")
                        .applyFont(.semiBold, size: 20)
                    
                    
                    QuizViewAnswerList()
                        .padding(.top, 16)
                    
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
                                 goRightCheckingQuesiton()
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
        }
    }
    
    private func navigateAfterFinish() {
        quizStore.completeQuiz {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    let context = router.getCurrentContext()
                    
                    if context == .onboarding {
//                        router.navigateTo(.streakView, from: .onboarding)
                    } else {
                        userManager.convertStartedQuizToCompletedQuiz(quizStore.currentQuiz)
                        quizStore.removeQuizFromStore(quizStore.currentQuiz)
                        router.popToRoot()
                    }
                }
            }
        }
    }
    
    private func goLeftCheckingQuesiton() {
        withAnimation {
            quizStore.checkAnswerToTheLeft()
        }
    }
    
    private func goRightCheckingQuesiton() {
        withAnimation {
            if quizStore.currentQuiz.isInReview {
                
                let result = quizStore.checkAnswerToTheRight()
                if result == .endOfQuiz {
                    self.finishQuizModal = true
                }
            } else {
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
        }
    }
    
    private func onClose() {
        withAnimation {
            if quizStore.currentQuiz.isInReview {
                self.finishQuizModal = true
            } else {
                alertManager.showQuizExitAlert(quizName: quizStore.currentQuiz.name) {
                    quizStore.quitQuiz { startedQuiz in
                        userManager.addStartedQuiz(startedQuiz)
                        quizStore.removeQuizFromStore(startedQuiz.quiz)
                        router.popBackStack()
                    }
                }
            }
        }
    }
}

#Preview {
    PreviewEnvironmentView {
        QuizView()
    }
}

private struct ReviewButtonControlls: View {
    
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
