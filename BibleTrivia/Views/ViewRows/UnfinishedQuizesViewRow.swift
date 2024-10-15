//
//  UnfinishedQuizesViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.10.24.
//

import SwiftUI

struct UnfinishedQuizesViewRow: View {
    @State var quizes = DummySVM.shared.quizes
    @State var openModal: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach($quizes, id: \.id) { quiz in
                        Button(action: {
                            print("I click on starting: \(quiz.name) quiz")

                            DummySVM.shared.chosenQuiz = quiz.wrappedValue
                            openModal = true
                        }) {
                            QuizSquareView(quiz: quiz)
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $openModal) {
            if let quiz = DummySVM.shared.chosenQuiz {
                ChooseQuizModal(quiz: quiz)
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    UnfinishedQuizesViewRow()
}
