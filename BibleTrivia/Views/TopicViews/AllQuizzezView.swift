//
//  AllQuizzezView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 24.10.25.
//

import SwiftUI

struct AllQuizzezView: View {
    @Environment(Router.self) private var router
    @Environment(UserStore.self) private var userStore
    @Environment(QuizStore.self) private var quizStore
    @Environment(TopicStore.self) private var topicStore
    
    @State private var openQuizModal: Bool = false
    
    var body: some View {
        ZStack {
            //Quizzes
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: Constants.vStackSpacing) {
                    
                    //Completed Quizzes
                    SectionTitle(title: "Completed")
                    ForEach(userStore.completedQuizzes.filter {$0.quiz.topicId == topicStore.currentTopic.id}) { completedQuiz in
                        CompletedQuizzezViewRow(completedQuiz: completedQuiz)
                            .padding(1)
                    }
                    
                    //New Quizzes
                    SectionTitle(title: "New")
                    FindQuizViewRow(quizes: quizStore.allQuizez.filter {$0.topicId == topicStore.currentTopic.id}) { quiz in
                        quizStore.chooseQuiz(quiz: quiz)
                        onQuizModal(open: true)
                    }
                }
            }
            .navigationTitle("Quizzes")
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
//        .onAppear {
//            for _ in 0..<3 {
//                userStore.addStartedQuiz(.init(sessionId: 0, quiz: .init()))
//                userStore.completedQuizzes.append(.init(quiz: .init(), sessionId: 0))
//                quizStore.allQuizez.append(.init())
//            }
//        }
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
