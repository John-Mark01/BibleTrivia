//
//  UnfinishedQuizesViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.10.24.
//

import SwiftUI

struct UnfinishedQuizesViewRow: View {
    
    
    @Environment(QuizStore.self) var quizStore
    @Binding var quizes: [Quiz]
    @Binding var isPresented: Bool
    @State private var goToQuiz: Bool = false
    @State var value = 0.0
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach($quizes, id: \.id) { quiz in
                        Button(action: {
                            print("I click on starting: \(quiz.name.wrappedValue) quiz")
                            quizStore.chooseQuiz(quiz: quiz.wrappedValue)
                            withAnimation(.snappy) {
                                isPresented = true
                            }
                        }) {
                            QuizSquareView(quiz: quiz)
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
