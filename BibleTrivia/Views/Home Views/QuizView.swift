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

    @State private var finishQuizModal: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            //MARK: ProgressView + Close
            HStack(spacing: 16) {
                LinearProgressView(progress: quizStore.chosenQuiz?.currentQuestionIndex ?? 0, goal: quizStore.chosenQuiz?.numberOfQuestions ?? 0)

                Spacer()
                
                Button(action: {
                    self.dismiss()
                    // close quiz
                    // custom alert -> "Do you want to quit \(Quiz.name)?"
                   
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
        
        .sheet(isPresented: $finishQuizModal) {
            FinishedQuizModal(quiz: quizStore.chosenQuiz!)
                .presentationDetents([.fraction(0.6)])
                .presentationDragIndicator(.visible)
        }
    }
    
}

#Preview {
    NavigationStack {
        QuizView()
            .environment(QuizStore())
    }
}
