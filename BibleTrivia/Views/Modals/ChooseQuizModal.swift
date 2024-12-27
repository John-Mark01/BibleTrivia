//
//  ChooseQuizModal.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 13.10.24.
//

import SwiftUI

struct ChooseQuizModal: View {
    
    @Binding var isPresented: Bool
    var quiz: Quiz
    let startQuiz: () -> ()
    let cancel: () -> ()
    
    var body: some View {
        
        ZStack {
            Color.black
                .opacity(0.1)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            VStack(alignment: .center, spacing: 10) {
                Text(quiz.name)
                    .foregroundStyle(Color.BTPrimary)
                    .modifier(CustomText(size: 20, font: .medium))
                    .padding(.top, 8)
                //MARK: Middle Info
                VStack(spacing: 22) {
                    // Level
                    HStack {
                        Image("medal-star")
                        Text("Level:")
                            .modifier(CustomText(size: 18, font: .medium))
                        
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(quiz.difficulty.getAsString())
                                .modifier(CustomText(size: 18, font: .regular))
                        }
                    }
                    
                    // Questions
                    HStack {
                        Image("task-square")
                        Text("Questions:")
                            .modifier(CustomText(size: 18, font: .medium))
                        
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(quiz.numberOfQuestions)")
                                .modifier(CustomText(size: 18, font: .regular))
                        }
                    }
                    
                    // Points
                    HStack {
                        Image("cup")
                        Text("Points:")
                            .modifier(CustomText(size: 18, font: .medium))
                        
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(quiz.totalPoints)")
                                .modifier(CustomText(size: 18, font: .regular))
                        }
                    }
                    
                    // Time
                    HStack {
                        Image("timer")
                        Text("Time:")
                            .modifier(CustomText(size: 18, font: .medium))
                        
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(Int(quiz.time.rounded())) minutes")
                                .modifier(CustomText(size: 18, font: .regular))
                        }
                    }
                }
//                .padding()
                
                Spacer()
                
                //MARK: Buttons
                VStack {
                    ActionButtons(title: "Start Quiz", isPrimary: true, action: {
                        withAnimation {
                            startQuiz()
                        }
                    })
                    ActionButtons(title: "Cancel", isPrimary: false ,action: {
                        withAnimation {
                            cancel()
                        }
                    })
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
    @Previewable @State var quiz = Quiz(name: "NewTestement", questions: [], time: 3, status: .new, difficulty: .deacon, totalPoints: 10)
    ChooseQuizModal(isPresented: .constant(true), quiz: quiz, startQuiz: {}, cancel: {})

}
