//
//  UnfinishedQuizesViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.10.24.
//

import SwiftUI

struct UnfinishedQuizesViewRow: View {
    var quizes: [StartedQuiz]
    var onChoseQuiz: (StartedQuiz) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(quizes, id: \.id) { quiz in
                        Button(action: {
                            onChoseQuiz(quiz)
                        }) {
                            QuizSquareView(quiz: quiz.quiz)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

//#Preview {
//    UnfinishedQuizesViewRow()
//}
