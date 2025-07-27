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
                    .applyFont(.medium, size: 20, textColor: .BTPrimary)
                    .padding(.top, 8)
                
                //MARK: Middle Info
                VStack(spacing: 22) {
                    // Level
                    HStack {
                        Image("medal-star")
                        Text("Level:")
                            .applyFont(.medium, size: 18)
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text(quiz.difficulty.getAsString())
                                .applyFont(.regular, size: 18)
                        }
                    }
                    
                    // Questions
                    HStack {
                        Image("task-square")
                        Text("Questions:")
                            .applyFont(.medium, size: 18)
                        
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(quiz.numberOfQuestions)")
                                .applyFont(.regular, size: 18)
                        }
                    }
                    
                    // Points
                    HStack {
                        Image("cup")
                        Text("Points:")
                            .applyFont(.medium, size: 18)
                        
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(quiz.totalPoints)")
                                .applyFont(.regular, size: 18)
                        }
                    }
                    
                    // Time
                    HStack {
                        Image("timer")
                        Text("Time:")
                            .applyFont(.medium, size: 18)
                        
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(Int(quiz.time.rounded())) minutes")
                                .applyFont(.regular, size: 18)
                        }
                    }
                }
//                .padding()
                
                Spacer()
                
                //MARK: Buttons
                VStack {
                    Button("Start Quiz") {
                        withAnimation {
                            startQuiz()
                        }
                    }
                    .buttonStyle(.primary)
                    
                    Button("Cancel") {
                        withAnimation {
                            cancel()
                        }
                    }
                    .buttonStyle(.secondary)
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
