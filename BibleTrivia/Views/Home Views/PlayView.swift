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
    @Environment(TopicStore.self) var topicStore
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
                            onCloseModal(.quiz)
                        }
                    )
                }
                
                if openTopicModal {
                    ChooseTopicModal(
                        topic: topicStore.currentTopic,
                        goToQuizez: {
//                            showAllTopics = true
                            //TODO: Navigate to all topics screen
                        }, cancel: {
                            onCloseModal(.topic)
                        }
                    )
                }
            }
            .zIndex(999)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    
                    //Quiz Update
                    QuizUpdateView()
                    
                    //Choose a topic
                    SectionTitle(title: "Choose a Topic")
                        .setTextButton("See all", action: {})
                    
                    TopicsCaurosel(topics: topicStore.allTopics) { topic in
                        topicStore.selectTopic(topic)
                        onOpenModal(.topic)
                    }
                    
                    //Quick Quiz
                    SectionTitle(title: "Quick Quiz")
                        .setTextButton("See all", action: {})
                    
                    QuizzezCarousel(quizez: quizStore.allQuizez) { quiz in
                        quizStore.chooseQuiz(quiz: quiz)
                        onOpenModal(.quiz)
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
                AllTopicsView(topics: topicStore.allTopics)
            }
        }
        .onDisappear { refreshTask?.cancel() }
    }
    
    private func onRefresh() {
        refreshTask = Task {
            await quizStore.refreshQuizzes(amount: 50)
            await topicStore.refreshTopics(amount: 50)
        }
    }
    
    private func onOpenModal(_ type: ModalType) {
        withAnimation(.snappy) {
            switch type {
            case .quiz:
                self.openQuizModal = true
            case .topic:
                self.openTopicModal = true
            }
        }
    }
    
    private func onCloseModal(_ type: ModalType) {
        withAnimation(.snappy) {
            switch type {
            case .quiz:
                self.openQuizModal = false
            case .topic:
                self.openTopicModal = false
            }
        }
    }
    
    private enum ModalType {
        case quiz
        case topic
    }
}

#Preview {
    PreviewEnvironmentView {
        PlayView()
    }
}
