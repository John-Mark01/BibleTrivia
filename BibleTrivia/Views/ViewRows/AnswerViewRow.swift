//
//  AnswerViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 16.10.24.
//

import SwiftUI

struct AnswerViewRow: View {
    @Environment(QuizStore.self) var quizStore
    
    @State private var selectionTapped: Bool = false
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 16) {
            
            ForEach(0..<quizStore.chosenQuiz!.currentQuestion.answers.count, id: \.self) { index in
                
                Button(action: {
                    selectionTapped.toggle()
                    
                    if !quizStore.chosenQuiz!.currentQuestion.answers[index].isSelected {
                        quizStore.selectAnswer(index: index)
                    } else {
                        quizStore.unSelectAnswer(index: index)
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(getBackgroundColor(for: index))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color.clear)
                                    .stroke(getStrokeColor(for: index), lineWidth: 2)
                            )
                        
                        HStack(alignment: .center, spacing: 16) {
                            
                            Circle()
                                .foregroundStyle(getCircleColor(for: index))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Text(quizStore.chosenQuiz!.currentQuestion.getAnswerABC(index: index))
                                        .foregroundStyle(getLetterColor(for: index))
                                )
                            
                            Text(quizStore.chosenQuiz!.currentQuestion.answers[index].text)
                                .foregroundStyle(getTextColor(for: index))
                                .modifier(CustomText(size: 16, font: .regular))
                            Spacer()
                        }
                        .padding(.horizontal, Constants.hPadding)
                    }
                    .frame(height: 50)
                    
                }
                .disabled(quizStore.chosenQuiz!.isInReview)
                .sensoryFeedback(.selection, trigger: selectionTapped)
            }
            
        }
    }
    // Helper functions to determine colors based on state
    private func getBackgroundColor(for index: Int) -> Color {
        let answer = quizStore.chosenQuiz!.currentQuestion.answers[index]
        if quizStore.chosenQuiz!.isInReview {
            if answer.isCorrect {
                return .BTPrimary
            }
            return .clear
        }
        return answer.isSelected ? .clear : .BTBackground
    }
    
    private func getStrokeColor(for index: Int) -> Color {
        let answer = quizStore.chosenQuiz!.currentQuestion.answers[index]
        if quizStore.chosenQuiz!.isInReview {
            if answer.isCorrect && answer.isSelected {
                return .BTBlack
            } else if answer.isSelected {
                return .BTIncorrect
            }
            return .BTStroke
        }
        return answer.isSelected ? .BTPrimary : .BTStroke
    }
    
    private func getCircleColor(for index: Int) -> Color {
        let answer = quizStore.chosenQuiz!.currentQuestion.answers[index]
        if quizStore.chosenQuiz!.isInReview {
            if answer.isCorrect {
                return .white
            } else if answer.isSelected {
                return .BTIncorrect
            }
            return .BTAnswer
        }
        return answer.isSelected ? .BTPrimary : .BTAnswer
    }
    
    private func getLetterColor(for index: Int) -> Color {
        let answer = quizStore.chosenQuiz!.currentQuestion.answers[index]
        if quizStore.chosenQuiz!.isInReview {
            if answer.isCorrect && answer.isSelected {
                return .BTPrimary
            } else if answer.isCorrect {
                return .BTPrimary
            } else if !answer.isCorrect {
                return .white
            }
            return .black
        }
        return answer.isSelected ? .white : .black
    }
    
    private func getTextColor(for index: Int) -> Color {
        let answer = quizStore.chosenQuiz!.currentQuestion.answers[index]
        if quizStore.chosenQuiz!.isInReview {
            if answer.isCorrect {
                return .white
            } else if answer.isSelected {
                return .BTIncorrect
            }
            return .BTBlack
        }
        return answer.isSelected ? .BTPrimary : .BTBlack
    }
}

#Preview {
    
    @Previewable @State var isSelected: Bool = false
    @Previewable @State var answer: Answer = Answer(isCorrect: false, isSelected: true, text: "The first man")
    ZStack {
        Color.BTBackground.ignoresSafeArea(.all)
        AnswerViewRow()
            .environment(QuizStore())
            .frame(width: 300, height: 50)
    }
  
}

