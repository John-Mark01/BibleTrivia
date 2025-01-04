//
//  FindQuizViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 15.10.24.
//

import SwiftUI

struct FindQuizViewRow: View {
    @Environment(QuizStore.self) var quizStore
    var quizes: [Quiz]
    @Binding var isPresented: Bool
    var body: some View {
        
        VStack(alignment: .leading) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(0..<quizes.count, id: \.self) { index in
                        Button(action: {
                            print("I click on starting: \(quizStore.allQuizez[index].name) quiz")
                            quizStore.chooseQuiz(quiz: quizStore.allQuizez[index])
                            withAnimation(.snappy) {
                                isPresented = true
                            }
                        }) {
                            QuizRectangleView(quiz: quizStore.allQuizez[index])
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

//#Preview {
//    var quiz: Quiz = Quiz(name: "Christian History", questions: [], time: 1, status: .new, difficulty: .deacon, totalPoints: 14)
//    FindQuizViewRow()
//}
