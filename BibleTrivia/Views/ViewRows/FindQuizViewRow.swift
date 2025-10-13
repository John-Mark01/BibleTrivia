//
//  FindQuizViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 15.10.24.
//

import SwiftUI

struct FindQuizViewRow: View {
    var quizes: [Quiz]
    var onChooseQuiz: (Quiz) -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(quizes, id: \.id) { quiz in
                    QuizRectangleView(quiz: quiz)
                        .makeButton(action: { onChooseQuiz(quiz) }, addHapticFeedback: true, feedbackStyle: .start)
                }
            }
        }
    }
}

//#Preview {
//    var quiz: Quiz = Quiz(name: "Christian History", questions: [], time: 1, status: .new, difficulty: .deacon, totalPoints: 14)
//    FindQuizViewRow()
//}
