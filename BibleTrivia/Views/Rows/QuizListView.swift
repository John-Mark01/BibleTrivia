//
//  QuizListView.swift
//  BibleTrivia
//

import SwiftUI

/// Vertical list of quizzes. Meant to be placed inside a parent `ScrollView`.
struct QuizListView: View {
    let quizzes: [Quiz]
    let onSelect: (Quiz) -> Void
    /// Called as each row appears; use it to trigger pagination.
    var onItemAppear: ((Quiz) async -> Void)?

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(quizzes) { quiz in
                QuizRectangleView(quiz: quiz)
                    .makeButton(action: { onSelect(quiz) }, addHapticFeedback: true, feedbackStyle: .start)
                    .task { await onItemAppear?(quiz) }
            }
        }
        .padding(1)
    }
}
