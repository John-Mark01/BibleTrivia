//
//  ChooseQuizModal.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 13.10.24.
//

import SwiftUI

struct ChooseQuizModal: View {
    @EnvironmentObject var router: Router
    @Environment(QuizStore.self) var quizStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(quizStore.chosenQuiz?.name ?? "")
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
                    
                    Text(quizStore.chosenQuiz?.difficulty.getAsString() ?? "")
                        .modifier(CustomText(size: 18, font: .label))
                }
                
                // Questions
                HStack {
                    Image(systemName: "list.bullet.clipboard.fill")
                    Text("Questions:")
                        .modifier(CustomText(size: 18, font: .label))
                    
                    Spacer()
                    
                    Text("\(quizStore.chosenQuiz?.numberOfQuestions)")
                        .modifier(CustomText(size: 18, font: .label))
                }
                
                // Points
                HStack {
                    Image(systemName: "trophy.fill")
                    Text("Points:")
                        .modifier(CustomText(size: 18, font: .label))
                    
                    Spacer()
                    
                    Text("\(quizStore.chosenQuiz?.totalPoints)")
                        .modifier(CustomText(size: 18, font: .label))
                }
                
                // Time
                HStack {
                    Image(systemName: "clock.fill")
                    Text("Time:")
                        .modifier(CustomText(size: 18, font: .label))
                    
                    Spacer()
                    
                    Text("\(Int(quizStore.chosenQuiz?.time.rounded() ?? 0)) minutes")
                        .modifier(CustomText(size: 18, font: .label))
                }
            }
            .padding()
            
            Spacer()
            
            //MARK: Buttons
            VStack {
                ActionButtons(title: "Start Quiz", isPrimary: true, action: {
                    quizStore.startQuiz() { startQuiz in
                        self.dismiss()
                        if startQuiz {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                router.navigate(to: .quizView)
                            }
                        } else {
                            //TODO: Create custom alert with - "Unexpected Error, no quiz selected!"
                        }
                    }
                })
                ActionButtons(title: "Cancel", isPrimary: false ,action: {
                    quizStore.cancelChoosingQuiz() {
                        self.dismiss()
                    }
                })
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
