//
//  FinishedQuizModal.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 19.10.24.
//

import SwiftUI

struct FinishedQuizModal: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: Router
    var quiz: Quiz
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image("Quiz")
            
            HStack(spacing: 10) {
                ForEach(quiz.questions, id:\.id) { question in
                    
                    if question.userAnswerIsCorrect {
                        ZStack {
                            Circle()
                                .fill(Color.BTPrimary)
                                .frame(width: 24, height: 23)
                            
                            Image("Tic")
                            
                        }
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.BTIncorrect)
                                .frame(width: 24, height: 23)
                            
                            Image("close")
                            
                        }
                    }
                }
            }
            .padding(.top, 40)
            
            Text(quiz.userPassedTheQuiz ? "You almost passed\n\(quiz.name)" : "You passed\n\(quiz.name)!")
                .modifier(CustomText(size: 20, font: .title))
            
            Text("Keep up the good work :)")
                .modifier(CustomText(size: 14, font: .body))
                .foregroundStyle(Color.BTLightGray)
            
            
            ActionButtons(title: "Continue", isPrimary: true) {
                router.navigate(to: .home)
            }
            
            ActionButtons(title: "Back To Quiz") {
                self.dismiss()
            }
        }
        .navigationBarBackButtonHidden()
        .background(Color.BTBackground)
        .padding()
    }
}

#Preview {
    @Previewable @State var quiz = DummySVM.shared.tempQuiz
    FinishedQuizModal(quiz: quiz)
}
