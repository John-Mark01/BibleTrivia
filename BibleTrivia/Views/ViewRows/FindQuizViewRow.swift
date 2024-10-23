//
//  FindQuizViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 15.10.24.
//

import SwiftUI

struct FindQuizViewRow: View {
    @Environment(QuizStore.self) var quizStore
    @State var quizes: [Quiz]
    @Binding var isPresented: Bool
    @State private var goToQuiz: Bool = false
    var body: some View {
        
        VStack(alignment: .leading) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach($quizes, id: \.id) { quiz in
                        Button(action: {
                            print("I click on starting: \(quiz.name.wrappedValue) quiz")
                            quizStore.chooseQuiz(quiz: quiz.wrappedValue)
                            withAnimation(.snappy) {
                                isPresented = true
                            }
                        }) {
                            QuizRectangleView(quiz: quiz)
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
