//
//  AnswerViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 16.10.24.
//

import SwiftUI

struct AnswerViewRow: View {
    @Environment(QuizStore.self) var quizStore
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 16) {
            
            ForEach(0..<quizStore.chosenQuiz!.currentQuestion.answers.count, id: \.self) { index in
                
                Button(action: {
                    quizStore.selectAnswer(index: index)
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(quizStore.chosenQuiz!.currentQuestion.answers[index].isSelected ? Color.clear : Color.BTBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color.clear)
                                    .stroke(quizStore.chosenQuiz!.currentQuestion.answers[index].isSelected ? Color.BTPrimary : Color.BTStroke, lineWidth: 2)
                            )
                        
                        HStack(alignment: .center, spacing: 16) {
                            
                            Circle()
                                .foregroundStyle(quizStore.chosenQuiz!.currentQuestion.answers[index].isSelected ? Color.BTPrimary : Color.BTAnswer)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Text(quizStore.chosenQuiz!.currentQuestion.getAnswerABC(index: index))
                                        .foregroundStyle(quizStore.chosenQuiz!.currentQuestion.answers[index].isSelected ? Color.white : Color.black)
                                )
                            
                            Text(quizStore.chosenQuiz!.currentQuestion.answers[index].text)
                                .foregroundStyle(quizStore.chosenQuiz!.currentQuestion.answers[index].isSelected ? Color.BTPrimary : Color.BTBlack)
                                .modifier(CustomText(size: 16, font: .body))
                            Spacer()
                        }
                        .padding(.horizontal, Constants.hPadding)
                    }
                    .frame(height: 50)
                    
                }
            }
            
        }
    }
}

#Preview {
    
    @Previewable @State var isSelected: Bool = false
    @Previewable @State var answer: Answer = Answer(isCorrect: false, isSelected: true, text: "The first man")
    ZStack {
        Color.BTBackground.ignoresSafeArea(.all)
        AnswerViewRow()
            .frame(width: 300, height: 50)
    }
}
