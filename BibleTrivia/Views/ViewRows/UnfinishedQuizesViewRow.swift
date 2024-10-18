//
//  UnfinishedQuizesViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.10.24.
//

import SwiftUI

struct UnfinishedQuizesViewRow: View {
    @Environment(QuizStore.self) var quizStore
    @State var quizes: [Quiz]
    @State var openModal: Bool = false
    @State private var goToQuiz: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach($quizes, id: \.id) { quiz in
                        Button(action: {
                            print("I click on starting: \(quiz.name.wrappedValue) quiz")
                            quizStore.chooseQuiz(quiz: quiz.wrappedValue)
                            openModal = true
                        }) {
                            QuizSquareView(quiz: quiz)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $openModal) {
            if let quiz = quizStore.chosenQuiz {
                ChooseQuizModal()
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)

            }
        }
    }
}

//#Preview {
//    UnfinishedQuizesViewRow()
//}
