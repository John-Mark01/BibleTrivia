//
//  PlayView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

struct PlayView: View {
    @EnvironmentObject var router: Router
    @Environment(QuizStore.self) var quizStore
    @State private var dummyTopics = DummySVM.shared.topics
    @State private var dummyQuizzez = DummySVM.shared.quizes
    @State private var openModal: Bool = false
    @State private var showAllTopics: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    //MARK: Quiz Update
                    QuizUpdateView()
                    
                    
                    //MARK: Choose a topic
                    HStack {
                        Text("Choose a Topic")
                            .modifier(CustomText(size: 20, font: .medium))
                        
                        Spacer()
                        
                        Button("See all") {
                            self.showAllTopics = true
                        }.tint(Color.BTBlack)
                    }
                    
                    TopicsViewRow(topics: dummyTopics, isPresented: $openModal)
                    
                    //MARK: Quick Quiz
                    HStack {
                        Text("Quick Quiz")
                            .modifier(CustomText(size: 20, font: .medium))
                        
                        Spacer()
                        
                        Button("See all") {
                            
                        }.tint(Color.BTBlack)
                    }
                    
                    QuizViewRow(quizez: dummyQuizzez, isPresented: $openModal)
                }
                .padding(.horizontal, Constants.hPadding)
                .padding(.vertical, 20)
                .background(Color.BTBackground)
                .navigationTitle("Play")
                .navigationBarTitleDisplayMode(.inline)
                .blur(radius: openModal ? 3 : 0)
                .disabled(openModal)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            
                        }) {
                            Image("Avatars/jacob")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .clipShape(
                                    Circle()
                                )
                                .background(
                                    Circle()
                                        .frame(width: 36, height: 36)
                                )
                            
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            
                        }) {
                            HStack(spacing: 4) {
                                Image("star")
                                
                                Text("\(326)")
                                    .modifier(CustomText(size: 18, font: .regular))
                                    .foregroundStyle(Color.BTBlack)
                            }
                        }
                    }
                }
                .navigationDestination(isPresented: $showAllTopics) {
                    AllTopicsView(topics: dummyTopics)
                }
            }
            .background(Color.BTBackground)
            
            if openModal {
                if let quiz = quizStore.chosenQuiz {
                    ChooseQuizModal(isPresented: $openModal, quiz: quiz, startQuiz: {
                        router.navigate(to: .quizView)
                    }, cancel: {
                        openModal = false
                    })
                }
            }
        }
        
    }
}

#Preview {
    NavigationStack {
        PlayView()
            .tint(Color.BTPrimary)
    }
//        .environment(QuizStore())
}
