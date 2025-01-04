//
//  QuizViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 23.10.24.
//

import SwiftUI

struct QuizViewRow: View {
    @Environment(QuizStore.self) var quizStore
    let quizez: [Quiz]
    @Binding var isPresented: Bool
    @State private var goToTopic: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(quizez, id: \.id) { quiz in
                        Button(action: {
                            print("I click on starting: \(quiz.name) quiz")
                            quizStore.chooseQuiz(quiz: quiz)
                            withAnimation(.snappy) {
                                isPresented = true
                            }
                        }) {
                            QuizCard(quiz: quiz)
                                .frame(width: 180, height: 130)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}
