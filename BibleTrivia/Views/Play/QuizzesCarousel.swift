//
//  QuizzesCarousel.swift
//  BibleTrivia
//

import SwiftUI

struct QuizzesCarousel: View {
    let quizzes: [Quiz]
    let onSelect: (Quiz) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(quizzes) { quiz in
                    QuizCard(quiz: quiz)
                        .makeButton(action: { onSelect(quiz) }, addHapticFeedback: true, feedbackStyle: .start)
                }
            }
            .padding(1)
        }
    }
}
