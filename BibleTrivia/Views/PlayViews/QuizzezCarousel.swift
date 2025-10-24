//
//  QuizViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 23.10.24.
//

import SwiftUI

struct QuizzezCarousel: View {
    let quizez: [Quiz]
    let onChooseQuiz: (Quiz) -> Void
   
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(quizez, id: \.id) { quiz in
                    QuizCard(quiz: quiz)
                        .makeButton(action: { onChooseQuiz(quiz) }, addHapticFeedback: true, feedbackStyle: .start)
                }
            }
            .padding(1)
        }
    }
}
