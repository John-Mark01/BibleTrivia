//
//  QuizUpdateView.swift
//  BibleTrivia
//

import SwiftUI

/// Banner on the Play tab: continue the latest unfinished quiz, or start a new one.
struct QuizUpdateView: View {
    let activeAttempt: QuizAttempt?
    let onContinue: (QuizAttempt) -> Void
    let onStartNew: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Image("Icon/bible_mini")
                    Text("Quiz Update")
                        .applyFont(.semiBold, size: 18, textColor: .white)
                }

                Group {
                    if let activeAttempt {
                        Text("You're \(Int(activeAttempt.progress * 100))% through \(activeAttempt.quiz.name)")
                    } else {
                        Text("Currently you don't have any active quiz")
                    }
                }
                .multilineTextAlignment(.leading)
                .applyFont(.regular, size: 15, textColor: .white)

                Spacer()

                Text(activeAttempt == nil ? "Start Quiz" : "Continue")
                    .applyFont(.medium, size: 14, textColor: .btPrimary)
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .background(RoundedRectangle(cornerRadius: 8).fill(.white))
                    .makeButton(action: {
                        if let activeAttempt { onContinue(activeAttempt) } else { onStartNew() }
                    }, addHapticFeedback: true)
            }
            .padding()

            Image("bible-study")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 130)
                .padding()
                .accessibilityHidden(true)

            Spacer(minLength: 0)
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(.btSecondary.gradient))
    }
}

#Preview {
    VStack {
        QuizUpdateView(activeAttempt: SampleData.inProgressAttempt, onContinue: { _ in }, onStartNew: {})
        QuizUpdateView(activeAttempt: nil, onContinue: { _ in }, onStartNew: {})
    }
    .applyViewPaddings()
}
