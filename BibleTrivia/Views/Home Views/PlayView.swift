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
    
    //Tasks
    @State private var refreshTask: Task<(), Error>?
    
    @State private var openQuizModal: Bool = false
    @State private var openTopicModal: Bool = false
    @State private var showAllTopics: Bool = false
    
    var body: some View {
        ZStack {
            Group {
                if openQuizModal {
                    ChooseQuizModal(
                        quiz: quizStore.currentQuiz,
                        startQuiz: {
                            router.navigateTo(.quizView)
                        }, cancel: {
                            onCloseQuizModal()
                        }
                    )
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
                    
                    QuizzezCarousel(quizez: quizStore.allQuizez) { quiz in
                        quizStore.chooseQuiz(quiz: quiz)
                        onOpenQuizModal()
                    }
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
        .onDisappear { refreshTask?.cancel() }
    }
    
    private func onRefresh() {
        refreshTask = Task {
            await quizStore.getQuizzezOnly(limit: 50)
        }
    }
    
    private func onOpenQuizModal() {
        withAnimation(.snappy) {
            self.openQuizModal = true
        }
    }
    
    private func onCloseQuizModal() {
        withAnimation(.snappy) {
            self.openQuizModal = false
        }
    }
}

#Preview {
    PreviewEnvironmentView {
        PlayView()
            .tint(Color.BTPrimary)
    }
}
