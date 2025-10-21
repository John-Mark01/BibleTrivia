//
//  HomeView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

struct HomeView: View {
    @Environment(Router.self) private var router
    @Environment(UserStore.self) private var userStore
    @Environment(QuizStore.self) var quizStore
    
    @State private var openQuizModal: Bool = false
    
    //Tasks
    @State private var startQuizTask: Task<(), Error>?
    @State private var resumeQuizTask: Task<(), Error>?
    
    private var userScore: String {
        String(userStore.user.totalPoints)
    }
    private var userStreak: String {
        String(userStore.user.streak)
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    //Top Buttons
                    HStack {
                        
                        Button("") {
                            
                        }
                        .buttonStyle(.score(score: userScore))
                        
                        Button("") {
                            
                        }
                        .buttonStyle(.streak(width: 123, streak: userStreak))
                    }
                    
                    Spacer()
                    
                    //Unfinished Quizes
                    if !userStore.startedQuizzes.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Unfinished Quizzes")
                                .applyFont(.medium, size: 20)
                            
                            
                            UnfinishedQuizesViewRow(
                                quizes: userStore.startedQuizzes,
                                onChoseQuiz: self.resumeQuiz(_:)
                            )
                        }
                    }
                    
                    //Find New Quizzes
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Find New Quizzes")
                            .applyFont(.medium, size: 20)
                        
                        FindQuizViewRow(quizes: quizStore.allQuizez) { quiz in
                            quizStore.chooseQuiz(quiz: quiz)
                            onOpenQuizModal()
                        }
                        
                    }
                    .padding(.top, 10)
                }
                .navigationTitle("Welcome, \(userStore.user.name)!")
                .navigationBarBackButtonHidden()
                .navigationBarTitleDisplayMode(.large)
                .blur(radius: openQuizModal ? 3 : 0)
                .disabled(openQuizModal)
                .blurTabBar(openQuizModal)
                .applyViewPaddings()
                .applyBackground()
                .applyAccountButton(avatar: Image("Avatars/jacob"), onTap: {
                    router.navigateTo(.account)
                })
            }
            .background(Color.BTBackground)
            
            if openQuizModal {
                ChooseQuizModal(
                    quiz: quizStore.currentQuiz,
                    startQuiz: {
                        self.startQuizTask = Task {
                            await quizStore.startQuiz {
                                router.navigateTo(.quizView)
                                onCloseQuizModal()
                            }
                        }
                    }, cancel: {
                        quizStore.cancelChoosingQuiz {
                            onCloseQuizModal()
                        }
                    })
            }
        }
        .onDisappear(perform: cancellAllTasks)
    }
    
    private func resumeQuiz(_ quiz: StartedQuiz) {
        self.resumeQuizTask = Task {
            await quizStore.resumeQuiz(quiz.quiz, from: quiz.sessionId)
            withAnimation(.snappy) {
//                openModal = true //TODO: Add new modal before resuming to quiz
                router.navigateTo(.quizView)
            }
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
    
    private func cancellAllTasks() {
        startQuizTask?.cancel()
        resumeQuizTask?.cancel()
    }
}

#Preview {
    PreviewEnvironmentView {
        HomeView()
    }
}
