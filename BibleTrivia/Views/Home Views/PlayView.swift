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
    @Environment(UserStore.self) var userStore
    

    @State private var openQuizModal: Bool = false
    @State private var openTopicModal: Bool = false
    @State private var showAllTopics: Bool = false
    
    var body: some View {
        ZStack {
            Group {
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
            .zIndex(999)
            
            ScrollView(showsIndicators: false) {
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
            }
            .refreshable { onRefresh()}
            .navigationTitle("Play")
            .navigationBarTitleDisplayMode(.inline)
            .blur(radius: (openQuizModal || openTopicModal) ? 3 : 0)
            .disabled(openQuizModal || openTopicModal)
            .blurTabBar(openQuizModal || openTopicModal)
            .applyViewPaddings()
            .applyBackground()
            .applyAccountButton(avatar: Image("Avatars/jacob"), onTap: {
                router.navigateTo(.account)
            })
            .toolbar { //TODO: Add this in a Generic View
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        
                    }) {
                        HStack(spacing: 4) {
                            Image("star")
                            
                            Text("\(userStore.user.totalPoints)")
                                .applyFont(.regular, size: 18)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showAllTopics) {
                AllTopicsView(topics: quizStore.allTopics)
            }
        }
    }
    
    private func onRefresh() {
        Task {
            do {
                try await quizStore.getQuizzezOnly(limit: 50)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    PreviewEnvironmentView {
        PlayView()
            .tint(Color.BTPrimary)
    }
}
