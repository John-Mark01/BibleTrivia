//
//  AnswerViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 16.10.24.
//

import SwiftUI

struct QuizViewAnswerList: View {
    @Environment(QuizStore.self) var quizStore
    @Environment(AlertManager.self) var alertManager
    
    var body: some View {
        ForEach(0..<quizStore.currentQuiz.currentQuestion.answers.count, id: \.self) { index in
            AnswerViewRow(
                answer: quizStore.currentQuiz.currentQuestion.answers[index],
                abcLetter: quizStore.currentQuiz.currentQuestion.getAnswerABC(index: index),
                selectAnswer: {quizStore.selectAnswer(index: index)},
                unselectAnswer: {quizStore.unselectAnswer(index: index)},
                isInReview: quizStore.currentQuiz.isInReview
            )
        }
    }
}


struct AnswerViewRow: View {
    
    @State private var selectionTapped: Bool = false
    var answer: Answer
    var abcLetter: String
    var selectAnswer: () -> Void
    var unselectAnswer: () -> Void
    var isInReview: Bool
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 16) {
            
            
            Button(action: {
                selectionTapped.toggle()
                
                if !answer.isSelected {
                    selectAnswer()
                } else {
                    unselectAnswer()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(getBackgroundColor())
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.clear)
                                .stroke(getStrokeColor(), lineWidth: 2)
                        )
                    
                    HStack(alignment: .center, spacing: 16) {
                        
                        Circle()
                            .foregroundStyle(getCircleColor())
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text(abcLetter)
                                    .foregroundStyle(getLetterColor())
                            )
                        
                        Text(answer.text)
                            .applyFont(.regular, size: 16, textColor: getTextColor())
                            
                        Spacer()
                    }
                    .padding(.horizontal, Constants.horizontalPadding)
                }
                .frame(height: 50)
                
            }
            .disabled(isInReview)
            .sensoryFeedback(.selection, trigger: selectionTapped)
        }
    }
    // Helper functions to determine colors based on state
    private func getBackgroundColor() -> Color {
       
        if isInReview {
            if answer.isCorrect {
                return .btPrimary
            }
            return .clear
        }
        return answer.isSelected ? .clear : .btBackground
    }
    
    private func getStrokeColor() -> Color {

        if isInReview {
            if answer.isCorrect && answer.isSelected {
                return .btBlack
            } else if answer.isSelected {
                return .btIncorrect
            }
            return .btStroke
        }
        return answer.isSelected ? .btPrimary : .btStroke
    }
    
    private func getCircleColor() -> Color {
     
        if isInReview {
            if answer.isCorrect {
                return .white
            } else if answer.isSelected {
                return .btIncorrect
            }
            return .btAnswer
        }
        return answer.isSelected ? .btPrimary : .btAnswer
    }
    
    private func getLetterColor() -> Color {
        
        if isInReview {
            if answer.isCorrect && answer.isSelected {
                return .btPrimary
            } else if answer.isCorrect {
                return .btPrimary
            } else if !answer.isCorrect {
                return .white
            }
            return .black
        }
        return answer.isSelected ? .white : .black
    }
    
    private func getTextColor() -> Color {
        if isInReview {
            if answer.isCorrect {
                return .white
            } else if answer.isSelected {
                return .btIncorrect
            }
            return .btBlack
        }
        return answer.isSelected ? .btPrimary : .btBlack
    }
}

//#Preview {
//    
//    @Previewable @State var isSelected: Bool = false
//    @Previewable @State var answer: Answer = Answer(isCorrect: false, isSelected: true, text: "The first man")
//    ZStack {
//        .btBackground.ignoresSafeArea(.all)
//        AnswerViewRow()
//            .environment(QuizStore())
//            .frame(width: 300, height: 50)
//    }
//  
//}
