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
    @Binding var isPresented: Bool
    var quiz: Quiz
    var onFinishQuiz: () -> ()
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.1)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(alignment: .center, spacing: 10) {
                Image("Quiz")
                
                HStack(spacing: 10) {
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
                .padding(.top, 40)
                if quiz.userPassedTheQuiz {
                    Text("You passed:\n\(quiz.name)!")
                        .multilineTextAlignment(.center)
                        .modifier(CustomText(size: 20, font: .title))
                } else {
                    Text("You almost passed:\n\(quiz.name)!")
                        .multilineTextAlignment(.center)
                        .modifier(CustomText(size: 20, font: .title))
                }
                
                
                
                if quiz.userPassedTheQuiz {
                    Text("Keep up the good work :)")
                        .modifier(CustomText(size: 14, font: .body))
                        .foregroundStyle(Color.BTLightGray)
                } else {
                    Text("Click on 'Back To Quiz to review your answers")
                        .modifier(CustomText(size: 14, font: .body))
                        .foregroundStyle(Color.BTLightGray)
                }
                
                Spacer()
                
                ActionButtons(title: "Continue", isPrimary: true) {
                    self.dismiss()
                    onFinishQuiz()
                }
                
                ActionButtons(title: "Back To Quiz", isPrimary: false) {
                    self.dismiss()
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

#Preview {
    @Previewable @State var quiz = DummySVM.shared.tempQuiz
    FinishedQuizModal(isPresented: .constant(true), quiz: quiz, onFinishQuiz: {dump(quiz)})
}
