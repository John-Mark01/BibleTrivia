//
//  ChooseQuizModal.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 13.10.24.
//

import SwiftUI

struct ChooseQuizModal: View {
    @EnvironmentObject var router: Router
    @Environment(\.dismiss) var dismiss
    @State var quiz: Quiz
    @Binding var goToQuiz: Bool
    
    @State private var quizManager = QuizManager()
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(quiz.name)
                .foregroundStyle(Color.BTPrimary)
                .modifier(CustomText(size: 20, font: .heading))
                .padding(.top, 8)
            //MARK: Middle Info
            VStack(spacing: 22) {
                // Level
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Image(systemName: "star.fill")
                    Text("Level:")
                        .modifier(CustomText(size: 18, font: .label))
                    
                    Spacer()
                    
                    Text(quiz.difficulty.getAsString())
                        .modifier(CustomText(size: 18, font: .label))
                }
                
                // Questions
                HStack {
                    Image(systemName: "list.bullet.clipboard.fill")
                    Text("Questions:")
                        .modifier(CustomText(size: 18, font: .label))
                    
                    Spacer()
                    
                    Text("\(quiz.numberOfQuestions)")
                        .modifier(CustomText(size: 18, font: .label))
                }
                
                // Points
                HStack {
                    Image(systemName: "trophy.fill")
                    Text("Points:")
                        .modifier(CustomText(size: 18, font: .label))
                    
                    Spacer()
                    
                    Text("\(quiz.totalPoints)")
                        .modifier(CustomText(size: 18, font: .label))
                }
                
                // Time
                HStack {
                    Image(systemName: "clock.fill")
                    Text("Time:")
                        .modifier(CustomText(size: 18, font: .label))
                    
                    Spacer()
                    
                    Text("\(Int(quiz.time.rounded())) minutes")
                        .modifier(CustomText(size: 18, font: .label))
                }
            }
            .padding()
            
            Spacer()
            
            //MARK: Buttons
            VStack {
                ActionButtons(title: "Start Quiz", isPrimary: true, action: {
                    self.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        quiz.startQuiz()
                        self.goToQuiz = true
                    }
                })
                ActionButtons(title: "Cancel", isPrimary: false ,action: { self.dismiss() })
            }
        }
        .padding()
    }
}

//#Preview {
//    @Previewable @State var quiz = Quiz(name: "NewTestement", questions: [], time: 3, status: .new, difficulty: .deacon, totalPoints: 10)
//            ChooseQuizModal(quiz: quiz)
//
//}
