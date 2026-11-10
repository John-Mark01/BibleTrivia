//
//  QuizSquareView.swift
//  BibleTrivia
//

import SwiftUI

/// Card for an unfinished quiz, showing how far the user got.
struct QuizSquareView: View {
    let attempt: QuizAttempt

    var body: some View {
        VStack(alignment: .leading) {
            Image("Icon/book")
                .padding(.leading, 20)
                .padding()
                .accessibilityHidden(true)

            HStack {
                VStack(alignment: .leading) {
                    Text(attempt.quiz.name)
                        .applyFont(.regular, size: 16)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    Text("\(attempt.session.answers.count)/\(attempt.quiz.numberOfQuestions) answered")
                        .applyFont(.regular, size: 10, textColor: .btLightGray)
                }
                .padding(1)

                Spacer()

                ZStack {
                    CircularProgressView(progress: attempt.progress)
                    Text(attempt.progress, format: .percent.precision(.fractionLength(0)))
                        .applyFont(.regular, size: 10, textColor: .btPrimary)
                }
                .frame(width: 40, height: 40)
            }
            .padding(8)
        }
        .frame(width: 180)
        .background(.btBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.btStroke, lineWidth: 2)
        )
    }
}

#Preview {
    QuizSquareView(attempt: SampleData.inProgressAttempt)
        .padding()
}
