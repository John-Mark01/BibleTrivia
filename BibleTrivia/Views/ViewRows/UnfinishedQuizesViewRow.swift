//
//  UnfinishedQuizesViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.10.24.
//

import SwiftUI

struct UnfinishedQuizesViewRow: View {
    @State var quizes: [Quiz]
    @State var openModal: Bool = false
    @State private var goToQuiz: Bool = false
    @State private var chosenQuiz: Quiz = Quiz(name: "Test", questions: [], time: 1, status: .new, difficulty: .newBorn, totalPoints: 0)
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach($quizes, id: \.id) { quiz in
                        Button(action: {
                            print("I click on starting: \(quiz.name) quiz")
                            self.chosenQuiz = quiz.wrappedValue
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
                ChooseQuizModal(quiz: quiz, goToQuiz: $goToQuiz)
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)
            }
        }
        .navigationDestination(isPresented: $goToQuiz) {
            QuizView(quiz: chosenQuiz)
        }
    }
}

//#Preview {
//    UnfinishedQuizesViewRow()
//}
