//
//  FindQuizViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 15.10.24.
//

import SwiftUI

struct FindQuizViewRow: View {
    @State private var openModal: Bool = false
    @State private var goToQuiz: Bool = false
    var quiz: Quiz
    var body: some View {
        Button(action: {
            openModal = true
        }) {
            VStack {
                HStack(spacing: 18) {
                    Circle()
                        .frame(width: 48, height: 48)
                        .foregroundStyle(Color.BTPrimary)
                        .overlay(
                            Image("Quiz_Pic")
                        )
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(quiz.name)
                                .modifier(CustomText(size: 14, font: .body))
                                .foregroundStyle(Color.BTBlack)
                            
                            Text("\(quiz.numberOfQuestions) " + "Questions")
                                .modifier(CustomText(size: 10, font: .body))
                                .foregroundStyle(Color.BTLightGray)
                            
                        }
                    }
                    Spacer()
                    
                    Image("Go_Arrow")
                        .padding()
                }
            }
            .padding()
            .cornerRadius(16)
            
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.clear)
                    .stroke(Color.BTStroke, lineWidth: 2)
            )
        }
        .sheet(isPresented: $openModal) {
            ChooseQuizModal(quiz: quiz, goToQuiz: $goToQuiz)
                .presentationDetents([.fraction(0.55)])
                .presentationDragIndicator(.visible)
        }
        .navigationDestination(isPresented: $goToQuiz) {
            QuizView(quiz: quiz)
        }
    }
}

#Preview {
    var quiz: Quiz = Quiz(name: "Christian History", questions: [], time: 1, status: .new, difficulty: .deacon, totalPoints: 14)
    FindQuizViewRow(quiz: quiz)
}
