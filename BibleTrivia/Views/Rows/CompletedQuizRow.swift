//
//  CompletedQuizRow.swift
//  BibleTrivia
//

import SwiftUI

struct CompletedQuizRow: View {
    let attempt: QuizAttempt

    private var session: QuizSession { attempt.session }
    private var isPassed: Bool { session.passed ?? false }

    var body: some View {
        BTContentBox {
            HStack(alignment: .center, spacing: 12) {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 70, height: 72)
                    .foregroundStyle(.btLightGray)
                    .overlay(Image("Quiz_Pic"))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(attempt.quiz.name)
                        .applyFont(.medium, size: 14, textColor: .btBlack)

                    if let completedAt = session.completedAt {
                        Text(completedAt, format: .dateTime.day().month().year())
                            .applyFont(.regular, size: 10, textColor: .btLightGray)
                    }

                    Text("\(session.correctAnswers)/\(session.totalQuestions) correct · \(session.pointsEarned) pts")
                        .applyFont(.semiBold, size: 14, textColor: .init(hex: "6A5ADF"))
                        .padding(.top, 8)

                    Spacer(minLength: 0)
                }

                Spacer()

                Text(isPassed ? "Passed" : "Failed")
                    .applyFont(.regular, size: 14, textColor: .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 3)
                    .background(isPassed ? .greenGradient : .redGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    CompletedQuizRow(attempt: SampleData.completedAttempt)
        .padding()
}
