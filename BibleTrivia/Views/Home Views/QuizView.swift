//
//  QuizView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 13.10.24.
//

import SwiftUI

struct QuizView: View {
    @Environment(\.dismiss) var dismiss
    @State var quiz: Quiz
    @State private var indexOfAnswer: Int = 0
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Progress View //TODO: Change to a custom one
            HStack {
                ProgressView(value: quiz.progressValue)
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
                    
                    Text("Question" + " \(quiz.currentQuestionIndex + 1)")
                    
                    Text(quiz.questions[0].question + "?")
                        .modifier(CustomText(size: 20, font: .questionTitle))
                    ScrollView {
                        
                        ForEach(0..<quiz.currentQuestion.answers.count, id: \.self) { index in
                            
                            AnswerViewRow(answer: quiz.currentQuestion.answers[index], questionNumber: index)
                                .frame(idealWidth: 343, idealHeight: 50)
                                .padding(.top, 16)
                        }
                    }
                        Spacer()
                        
                    HStack(alignment: .center, spacing: 20) {
                            Spacer()
                            
                            Text("NEXT")
                                .modifier(CustomText(size: 14, font: .body))
                                .foregroundStyle(Color.BTPrimary)
                            
                            Button(action: {
                                quiz.moveToNextQuestion()
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
    @Previewable @State var quiz = DummySVM.shared.tempQuiz
    NavigationStack {
        QuizView(quiz: quiz)
    }
}
