//
//  PlayView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

struct PlayView: View {
    @Environment(Router.self) private var router
    @Environment(QuizStore.self) var quizStore
    
//    @State private var dummyTopics = DummySVM.shared.topics
//    @State private var dummyQuizzez = DummySVM.shared.quizes
    @State private var openQuizModal: Bool = false
    @State private var openTopicModal: Bool = false
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
                            .applyFont(.medium, size: 20)
                        
                        Spacer()
                        
                        Button("See all") {
                            self.showAllTopics = true
                        }
                        .tint(Color.BTBlack)
                    }
                    
                    TopicsViewRow(topics: quizStore.allTopics, isPresented: $openTopicModal)
                    
                    //MARK: Quick Quiz
                    HStack {
                        Text("Quick Quiz")
                            .applyFont(.medium, size: 20)
                        
                        Spacer()
                        
                        Button("See all") {
                            
                        }.tint(Color.BTBlack)
                    }
                    
                    QuizViewRow(quizez: quizStore.allQuizez, isPresented: $openQuizModal)
                }
                .padding(.horizontal, Constants.horizontalPadding)
                .padding(.vertical, 20)
                .background(Color.BTBackground)
                .navigationTitle("Play")
                .navigationBarTitleDisplayMode(.inline)
                .blur(radius: (openQuizModal || openTopicModal) ? 3 : 0)
                .disabled(openQuizModal || openTopicModal)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            router.navigateTo(.account)
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
                                    .applyFont(.regular, size: 18)
                            }
                        }
                    }
                }
                .navigationDestination(isPresented: $showAllTopics) {
                    AllTopicsView(topics: quizStore.allTopics)
                }
            }
            .refreshable {
                Task {
                    do {
                        try await quizStore.getQuizzezOnly(limit: 50)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .background(Color.BTBackground)
            
            if openQuizModal {
                if let quiz = quizStore.chosenQuiz {
                    ChooseQuizModal(isPresented: $openQuizModal, quiz: quiz, startQuiz: {
                        router.navigateTo(.quizView)
                    }, cancel: {
                        openQuizModal = false
                    })
                }
            }
            if openTopicModal {
                if let topic = quizStore.chosenTopic {
                    ChooseTopicModal(isPresented: $openTopicModal, topic: topic, goToQuizez: {
                        showAllTopics = true
                    }, close: {
                        openTopicModal = false
                    })
                }
            }
        }
        
    }
}

//#Preview {
//    NavigationStack {
//        PlayView()
//            .tint(Color.BTPrimary)
//    }
//        .environment(QuizStore())
//}
