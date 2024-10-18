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


    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Progress View //TODO: Change to a custom one
            HStack {
                ProgressView(value: quizStore.chosenQuiz?.progressValue)
                    .progressViewStyle(.linear)
                    .tint(Color.BTPrimary)
                    .scaleEffect(x: 1, y: 3, anchor: .center)
                
                
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
                    
                    Text((quizStore.chosenQuiz?.questions[quizStore.chosenQuiz?.currentQuestionIndex ?? 0].text ?? "") + "?")
                        .modifier(CustomText(size: 20, font: .questionTitle))
                    ScrollView {
                        
                        ForEach(0..<quizStore.chosenQuiz!.currentQuestion.answers.count, id: \.self) { index in
                            
                                AnswerViewRow(answer: quizStore.chosenQuiz!.currentQuestion.answers[index], questionNumber: index)
                                    .frame(idealWidth: 343, idealHeight: 50)
                                    .padding(.top, 16)
                                    .onTapGesture {
                                        quizStore.selectAnswer(index: index)
                                    }
                        }
                    }
                        Spacer()
                        
                    HStack(alignment: .center, spacing: 20) {
                            Spacer()
                            
                            Text("NEXT")
                                .modifier(CustomText(size: 14, font: .body))
                                .foregroundStyle(Color.BTPrimary)
                            
                            Button(action: {
                                //TODO: Next question
                                quizStore.answerQuestion() {
                                    withAnimation {
                                        quizStore.toNextQuestion()
                                    }
                                }
                            }) {
                                Image("Arrow")
                                    .tint(Color.white)
                            }
                            .frame(width: 67, height: 60)
                            .buttonStyle(ThreeDButton())
                        }
                
            }
            .background(Color.BTBackground)
        }
        .navigationBarBackButtonHidden()
        .padding(.horizontal, Constants.hPadding)
        .padding(.vertical, Constants.vPadding)
        .background(Color.BTBackground)
    }
    
}

#Preview {
    NavigationStack {
        QuizView()
            .environment(QuizStore())
    }
}
