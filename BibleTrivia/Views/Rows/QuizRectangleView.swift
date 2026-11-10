//
//  QuizRectangleView.swift
//  BibleTrivia
//

import SwiftUI

struct QuizRectangleView: View {
    let quiz: Quiz

    var body: some View {
        HStack(spacing: 18) {
            Circle()
                .frame(width: 48, height: 48)
                .foregroundStyle(.btPrimary)
                .overlay(Image("Quiz_Pic"))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(quiz.name)
                    .applyFont(.regular, size: 14)
                    .multilineTextAlignment(.leading)

                Text("\(quiz.numberOfQuestions) Questions · \(quiz.difficulty.title)")
                    .applyFont(.regular, size: 10, textColor: .btLightGray)
            }

            Spacer()

            Image("Icon/navigation_arrow")
                .padding()
                .accessibilityHidden(true)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.btStroke, lineWidth: 2)
        )
        .contentShape(Rectangle())
    }
}

#Preview {
    QuizRectangleView(quiz: SampleData.quizzes[0])
        .padding()
}
