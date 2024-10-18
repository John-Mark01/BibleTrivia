//
//  AnswerViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 16.10.24.
//

import SwiftUI

struct AnswerViewRow: View {
    @Environment(QuizStore.self) var quizStore
    @State var answer: Answer
    var questionNumber: Int
    private var answerLabel: String {
        switch questionNumber {
        case 0:
            return "A"
        case 1:
            return "B"
        case 2:
            return "C"
        case 3:
            return "D"
        default:
            return "A"
        }
        
    }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(answer.isSelected ? Color.clear : Color.BTBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.clear)
                        .stroke(answer.isSelected ? Color.BTPrimary : Color.BTStroke, lineWidth: 2)
                )
            
            HStack(alignment: .center, spacing: 16) {
                
                Circle()
                    .foregroundStyle(answer.isSelected ? Color.BTPrimary : Color.BTAnswer)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text(answerLabel)
                            .foregroundStyle(answer.isSelected ? Color.white : Color.black)
                    )
                
                Text(answer.text)
                    .foregroundStyle(answer.isSelected ? Color.BTPrimary : Color.BTBlack)
                    .modifier(CustomText(size: 16, font: .body))
                Spacer()
            }
            .padding(.horizontal, Constants.hPadding)
        }
    }
}

#Preview {
    
    @Previewable @State var isSelected: Bool = false
    @Previewable @State var answer: Answer = Answer(isCorrect: false, isSelected: true, text: "The first man")
    ZStack {
        Color.BTBackground.ignoresSafeArea(.all)
        AnswerViewRow(answer: answer, questionNumber: 0)
            .frame(width: 300, height: 50)
    }
}
