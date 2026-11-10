//
//  UnfinishedQuizzesRow.swift
//  BibleTrivia
//

import SwiftUI

struct UnfinishedQuizzesRow: View {
    let attempts: [QuizAttempt]
    let onSelect: (QuizAttempt) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(attempts) { attempt in
                    Button { onSelect(attempt) } label: {
                        QuizSquareView(attempt: attempt)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(1)
        }
    }
}
