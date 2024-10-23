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
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Question" + " \((quizStore.chosenQuiz?.currentQuestionIndex ?? 0) + 1)")
                        .modifier(CustomText(size: 14, font: .questionTitle))
                    
                    Text((quizStore.chosenQuiz?.questions[quizStore.chosenQuiz?.currentQuestionIndex ?? 0].text ?? "") + "?")
                        .modifier(CustomText(size: 20, font: .questionTitle))
                    
                    
                    AnswerViewRow()
                        .padding(.top, 16)
                    
                    Spacer()
                    
                    HStack(alignment: .center, spacing: 20) {
                        Spacer()
                        
                        Text("NEXT")
                            .modifier(CustomText(size: 14, font: .body))
                            .foregroundStyle(Color.BTPrimary)
                        
                        Button(action: {
                            //TODO: Next question
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
                FinishedQuizModal(isPresented: $finishQuizModal, quiz: quizStore.chosenQuiz!) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        router.navigateToRoot()
                    }
                }
            }
            // Normal Alert
            if alertIsPresented {
                AlertDialog(isPresented: $alertIsPresented, title: quizStore.alertTitle, message: quizStore.alertMessage, buttonTitle: quizStore.alertButtonTitle, primaryAction: { router.navigateToRoot() }, isAnotherAction: isActionFromQuizStore)
            }
        }
    }
    
}

#Preview {
    NavigationStack {
        QuizView()
            .environment(QuizStore())
    }
}
