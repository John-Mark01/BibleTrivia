//
//  ChooseQuizModal 2.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 9.11.24.
//

import SwiftUI

struct ChooseTopicModal: View {
    let topic: Topic
    let goToQuizez: () -> Void
    let cancel: () -> Void
    
    var body: some View {
        
        ZStack {
            Color.black
                .opacity(0.1)
                .onTapGesture {
                    withAnimation { cancel() }
                }
            
            VStack(alignment: .center, spacing: 10) {
                Text(topic.name)
                    .applyFont(.medium, size: 20)
                    .padding(.top, 8)
                
                //MARK: Middle Info
                VStack(spacing: 22) {
                    // Level
                    HStack {
                        Image("medal-star")
                        Text("Status:")
                            .applyFont(.medium, size: 18)
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text(topic.status.stringValue)
                                .applyFont(.regular, size: 18)
                        }
                    }
                    
                    // Questions
                    HStack {
                        Image("task-square")
                        Text("Completed Quizez:")
                            .applyFont(.medium, size: 18)
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("\(topic.playedQuizzes.count)/\(topic.numberOfQuizes)")
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
                            Text("\(topic.totalPoints)")
                                .applyFont(.regular, size: 18)
                        }
                    }
                    
                    // Time
                    LinearProgressView(progress: topic.playedQuizzes.count, goal: topic.numberOfQuizes)
                }

                Spacer()
                
                //MARK: Buttons
                VStack {
                    Button("View Quizez") {
                        withAnimation { goToQuizez() }
                    }
                    .buttonStyle(.primary)
                    
                    Button("Close") {
                        withAnimation { cancel() }
                    }
                    .buttonStyle(.secondary)
                }
            }
            .padding(25)
            .background(.btBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .fixedSize(horizontal: false, vertical: true)
            .padding(30)
        }
        .ignoresSafeArea()
    }
}
