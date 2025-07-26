//
//  FinishedQuizModal.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 19.10.24.
//

import SwiftUI

struct FinishedQuizModal: View {
    @Environment(\.dismiss) var dismiss
    @Environment(Router.self) private var router
    @Environment(QuizStore.self) private var quizStore
    @Binding var isPresented: Bool
    var quiz: Quiz
    var onFinishQuiz: () -> ()
    var onReviewQuiz: () -> ()
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.1)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(alignment: .center, spacing: 10) {
                Image("Quiz")
                
                FlowLayout(spacing: 12) {
                    ForEach(quiz.questions, id:\.id) { question in
                        
                        if question.userAnswerIsCorrect {
                            ZStack {
                                Circle()
                                    .fill(Color.BTPrimary)
                                    .frame(width: 24, height: 24)
                                
                                Image("Tic")
                                
                            }
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color.BTIncorrect)
                                    .frame(width: 24, height: 24)
                                
                                Image("close_white")
                                
                                
                            }
                        }
                    }
                }
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 5, trailing: 0))
                if quizStore.hasUserPassedQuiz() {
                    Text("You passed:\n\(quiz.name)!")
                        .applyFont(.semiBold, size: 20)
                        .multilineTextAlignment(.center)
                } else {
                    Text("You almost passed:\n\(quiz.name)!")
                        .applyFont(.semiBold, size: 20)
                        .multilineTextAlignment(.center)
                }
                
                
                
                if quizStore.hasUserPassedQuiz() {
                    Text("Keep up the good work :)")
                        .applyFont(.regular, size: 14, textColor: .BTLightGray)
                } else {
                    Text("Click on 'Back To Quiz' to review your answers")
                        .applyFont(.regular, size: 14, textColor: .BTLightGray)
                }
                
                Spacer()
                
                ActionButtons(title: "Continue", isPrimary: true) {
//                    self.dismiss()
                    onFinishQuiz()
                }
                
                ActionButtons(title: "Back To Quiz", isPrimary: false) {
                    onReviewQuiz()
                    isPresented = false
                }
            }
            .padding(25)
            .background(Color.BTBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .fixedSize(horizontal: false, vertical: true)
            .padding(30)
        }
        .ignoresSafeArea()
    }
}

//#Preview {
//    @Previewable @State var quiz = DummySVM.shared.tempQuiz
//    FinishedQuizModal(isPresented: .constant(true), quiz: quiz, onFinishQuiz: {dump(quiz)}, onReviewQuiz: {})
//}
