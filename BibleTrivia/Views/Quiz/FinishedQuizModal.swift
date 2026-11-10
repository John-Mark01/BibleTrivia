//
//  FinishedQuizModal.swift
//  BibleTrivia
//

import SwiftUI

/// Results shown after a quiz is completed. Pass/fail and points come from the server.
struct FinishedQuizModal: View {
    let player: QuizPlayer
    let completion: QuizCompletion
    let onContinue: () -> Void
    let onReview: () -> Void

    private var session: QuizSession { completion.session }
    private var passed: Bool { session.passed ?? false }

    var body: some View {
        ZStack {
            Color.black.opacity(0.1)

            VStack(alignment: .center, spacing: 10) {
                Image("Quiz")
                    .accessibilityHidden(true)

                FlowLayout(spacing: 12) {
                    ForEach(player.quiz.questions) { question in
                        let correct = player.isAnsweredCorrectly(question)
                        ZStack {
                            Circle()
                                .fill(correct ? .btPrimary : .btIncorrect)
                                .frame(width: 24, height: 24)
                            Image(correct ? "Icon/tic" : "Icon/close_white")
                        }
                        .accessibilityLabel(correct ? "Correct" : "Incorrect")
                    }
                }
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 5, trailing: 0))

                Text(passed ? "You passed:\n\(player.quiz.name)!" : "You almost passed:\n\(player.quiz.name)!")
                    .applyFont(.semiBold, size: 20)
                    .multilineTextAlignment(.center)

                Text("\(session.correctAnswers)/\(session.totalQuestions) correct · +\(session.pointsEarned) points")
                    .applyFont(.medium, size: 15, textColor: .btPrimary)

                if completion.leveledUp {
                    Text("Level up! You're now a \(completion.level.title) 🎉")
                        .applyFont(.medium, size: 14, textColor: .btBlack)
                } else {
                    Text(passed ? "Keep up the good work :)" : "Review your answers to learn more.")
                        .applyFont(.regular, size: 14, textColor: .btLightGray)
                }

                Spacer()

                Button("Continue", action: onContinue)
                    .buttonStyle(.primary(height: 15))

                Button("Review Answers", action: onReview)
                    .buttonStyle(.secondary(height: 15))
            }
            .padding(25)
            .background(.btBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .fixedSize(horizontal: false, vertical: true)
            .padding(30)
        }
        .ignoresSafeArea()
        .sensoryFeedback(passed ? .success : .warning, trigger: session.id)
    }
}
