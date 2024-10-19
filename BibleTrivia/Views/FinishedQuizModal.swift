//
//  FinishedQuizModal.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 19.10.24.
//

import SwiftUI

struct FinishedQuizModal: View {
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
        }
    }
}

#Preview {
    @Previewable @State var quiz = DummySVM.shared.tempQuiz
    FinishedQuizModal(quiz: quiz)
}
