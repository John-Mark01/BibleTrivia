//
//  ChooseQuizModal 2.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 9.11.24.
//


import SwiftUI

struct ChooseTopicModal: View {
    
    @Binding var isPresented: Bool
    var topic: Topic
    let goToQuizez: () -> ()
    let close: () -> ()
    
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
                Text(topic.name)
                    .foregroundStyle(Color.BTPrimary)
                    .modifier(CustomText(size: 20, font: .medium))
                    .padding(.top, 8)
                //MARK: Middle Info
                VStack(spacing: 22) {
                    // Level
                    HStack {
                        Image("medal-star")
                        Text("Status:")
                            .modifier(CustomText(size: 18, font: .medium))
                        
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(topic.status.stringValue)
                                .modifier(CustomText(size: 18, font: .regular))
                        }
                    }
                    
                    // Questions
                    HStack {
                        Image("task-square")
                        Text("Quizez:")
                            .modifier(CustomText(size: 18, font: .medium))
                        
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(topic.numberOfQuizes)")
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
                            Text("\(topic.totalPoints)")
                                .modifier(CustomText(size: 18, font: .regular))
                        }
                    }
                    
                    // Time
                    HStack {
                        LinearProgressView(progress: Int(topic.completenesLevel), goal: topic.numberOfQuizes)
                    }
                }

                
                Spacer()
                
                //MARK: Buttons
                VStack {
                    ActionButtons(title: "View Quizez", isPrimary: true, action: {
                        withAnimation {
                            goToQuizez()
                        }
                    })
                    ActionButtons(title: "Close", isPrimary: false ,action: {
                        withAnimation {
                            close()
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

