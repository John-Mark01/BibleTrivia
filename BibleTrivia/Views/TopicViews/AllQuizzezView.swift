//
//  AllQuizzezView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 24.10.25.
//

import SwiftUI

struct AllQuizzezView: View {
    @Environment(Router.self) private var router
    @Environment(QuizStore.self) private var quizStore
    @Environment(TopicStore.self) private var topicStore
    
    @State private var openQuizModal: Bool = false
    @State private var isPaginating: Bool = false
    
    var body: some View {
        ZStack {
            //Quizzes
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: Constants.vStackSpacing) {
                    
                    //Completed Quizzes
                    SectionTitle(title: "Completed")
                    ForEach(topicStore.completedQuizzesForSelectedTopic) { completedQuiz in
                        CompletedQuizzezViewRow(completedQuiz: completedQuiz)
                            .padding(1)
                    }
                    
                    //New Quizzes
                    SectionTitle(title: "New")
                    
                    FindQuizViewRow(quizes: topicStore.quizzesForSelectedTopic) { quiz in
                        quizStore.chooseQuiz(quiz: quiz)
                        onQuizModal(open: true)
                    }
                    ForEach(Array(topicStore.quizzesForSelectedTopic.enumerated()), id: \.element.id) { index, quiz in
                        QuizRectangleView(quiz: quiz)
                            .makeButton(action: { quizStore.chooseQuiz(quiz: quiz) }, addHapticFeedback: true, feedbackStyle: .start)
                            .task {
                                guard topicStore.quizzesForSelectedTopic.count > 10 else { return }
                                if index == topicStore.quizzesForSelectedTopic.count - 1 {
                                    isPaginating = true
                                    await topicStore.loadNeverPlayedQuizzesForTopic(
                                        limit: 5,
                                        offset: topicStore.quizzesForSelectedTopic.count
                                    )
                                    isPaginating = false
                                }
                            }
                            .padding(1)
                    }
                }
                
                //Loading indicator
                if isPaginating {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(.btPrimary)
                            .controlSize(.large)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle(topicStore.currentTopic.name)
            .navigationBarTitleDisplayMode(.inline)
            .blur(radius: openQuizModal ? 3 : 0)
            .disabled(openQuizModal)
            .applyViewPaddings(.horizontal)
            .applyBackground()
            
            //Modal
            Group {
                if openQuizModal {
                    ChooseQuizModal(
                        quiz: quizStore.currentQuiz,
                        startQuiz: {
                            Task {
                                await quizStore.startQuiz {
                                    router.navigateTo(.quizView)
                                    onQuizModal(open: false)
                                }
                            }
                        }, cancel: {
                            quizStore.cancelChoosingQuiz {
                                onQuizModal(open: false)
                            }
                        }
                    )
                }
            }
            .zIndex(999)
        }
        .task {
            await topicStore.loadNeverPlayedQuizzesForTopic(limit: 10)
            await topicStore.loadCompletedQuizzesForTopic(limit: 10)
        }
    }
    
    private func onQuizModal(open shouldOpen: Bool) {
        withAnimation {
            if shouldOpen {
                self.openQuizModal = true
            } else {
                self.openQuizModal = false
            }
        }
    }
}

#Preview {
    PreviewEnvironmentView {
        AllQuizzezView()
    }
}
