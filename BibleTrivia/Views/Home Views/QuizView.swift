//
//  QuizView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 13.10.24.
//

import SwiftUI

struct QuizView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(QuizStore.self) var quizStore
    @EnvironmentObject var router: Router
    
    @State private var finishQuizModal: Bool = false
    @State private var alertIsPresented: Bool = false
    @State private var isActionFromQuizStore: Bool = false
    
    // Sensor Feedback Variables
    @State private var nextButtonTapped: Bool = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 10) {
                //MARK: ProgressView + Close
                HStack(spacing: 16) {
                    LinearProgressView(progress: quizStore.chosenQuiz?.questionNumber ?? 0, goal: quizStore.chosenQuiz?.numberOfQuestions ?? 0)
                    
                    Spacer()
                    
                    Button(action: {
                        isActionFromQuizStore = false
                        alertIsPresented = true
                        quizStore.alertTitle = "Quit Quiz?"
                        quizStore.alertMessage = "Do want to quit \(quizStore.chosenQuiz?.name ?? "")?\nYou can still finish your quiz later."
                        quizStore.alertButtonTitle = "Close Quiz"
                    }) {
                        Image("close")
                    }
                    .sensoryFeedback(.error, trigger: alertIsPresented)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Question" + " \((quizStore.chosenQuiz?.currentQuestionIndex ?? 0) + 1)")
                        .modifier(CustomText(size: 14, font: .semiBold))
                    
                    Text((quizStore.chosenQuiz?.questions[quizStore.chosenQuiz?.currentQuestionIndex ?? 0].text ?? "") + "?")
                        .modifier(CustomText(size: 20, font: .semiBold))
                    
                    
                    AnswerViewRow()
                        .padding(.top, 16)
                    
                    
                    if quizStore.chosenQuiz!.isInReview {
                        HStack {
                            Spacer()
                            Text(quizStore.chosenQuiz!.currentQuestion.userAnswerIsCorrect ? "Correct!" : "Incorrect...")
                                .modifier(CustomText(size: 20, font: .medium))
                                .foregroundStyle(Color.BTBlack)
                            Spacer()
                        }
                        .padding()
                    }
                    
                    Spacer()
                    if quizStore.chosenQuiz!.isInReview {
                        HStack(alignment: .center, spacing: 20) {
                            
                            Text("PREVIOUS QUESTION")
                                .modifier(CustomText(size: 14, font: .regular))
                                .foregroundStyle(Color.BTPrimary)
                            Spacer()
                            
                            Text("NEXT QUESTION")
                                .modifier(CustomText(size: 14, font: .regular))
                                .foregroundStyle(Color.BTPrimary)
                            
                        }
                        
                    } else {
                        HStack(alignment: .center, spacing: 20) {
                            Spacer()
                            
                            Text("NEXT")
                                .modifier(CustomText(size: 14, font: .regular))
                                .foregroundStyle(Color.BTPrimary)
                            
                            Button(action: {
                                //TODO: Next question
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
            .padding(.horizontal, Constants.hPadding)
            .padding(.vertical, Constants.vPadding)
            .background(Color.BTBackground)
            .blur(radius: alertIsPresented || finishQuizModal ? 3 : 0)
            .disabled(alertIsPresented || finishQuizModal)
            
            if finishQuizModal {
                FinishedQuizModal(isPresented: $finishQuizModal, quiz: quizStore.chosenQuiz!, onFinishQuiz: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                        quizStore.finishQuiz()
                        router.navigateToRoot()
                    }
                }, onReviewQuiz: {
                    quizStore.enterQuizReviewMode()
                })
            }
            // Normal Alert
            if alertIsPresented {
                AlertDialog(isPresented: $alertIsPresented, title: quizStore.alertTitle, message: quizStore.alertMessage, buttonTitle: quizStore.alertButtonTitle, primaryAction: { router.navigateToRoot() }, isAnotherAction: isActionFromQuizStore)
            }
        }
        .gesture(
                DragGesture()
                    .onEnded { gesture in
                        let startX = gesture.startLocation.x
                        let width = UIScreen.main.bounds.width
                        
                        // Left edge detection (e.g., first 50 pixels)
                        if startX < 50 {
                            print("Left edge swipe detected")
                            withAnimation {
                                if quizStore.chosenQuiz!.isInReview {
                                    quizStore.checkAnswerToTheLeft { error in
                                        withAnimation {
                                            isActionFromQuizStore = true
                                            alertIsPresented = error
                                        }
                                    }
                                }
                                // Handle left edge swipe
                            }
                        }
                        
                        // Right edge detection (e.g., last 50 pixels)
                        if startX > width - 50 {
                            print("Right edge swipe detected")
                            if quizStore.chosenQuiz!.isInReview {
                                withAnimation {
                                    quizStore.checkAnswerToTheRight {
                                        withAnimation {
                                            finishQuizModal = true
                                        }
                                    }
                                }
                                // Handle right edge swipe
                            }
                        }
                    }
        )
    }
    
}

//#Preview {
//    NavigationStack {
//        QuizView()
//            .environment(QuizStore())
//    }
//}
