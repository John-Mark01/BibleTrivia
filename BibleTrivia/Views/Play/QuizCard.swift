//
//  QuizCard.swift
//  BibleTrivia
//

import SwiftUI

struct QuizCard: View {
    let quiz: Quiz

    var body: some View {
        BTContentBox {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(quiz.name)
                        .applyFont(.semiBold, size: 16)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    Spacer()

                    Text(quiz.difficulty.title)
                        .applyFont(.medium, size: 12, textColor: .btPrimary)
                }

                Text("\(quiz.numberOfQuestions) questions")
                    .applyFont(.regular, size: 14, textColor: .btLightGray)

                Text("\(quiz.totalPoints) points")
                    .applyFont(.regular, size: 16, textColor: .btPrimary)
                    .padding(.top, 8)
            }
        }
        .frame(minWidth: 180, maxWidth: 200, maxHeight: 130)
    }
}

#Preview {
    QuizCard(quiz: SampleData.quizzes[0])
        .padding()
}
