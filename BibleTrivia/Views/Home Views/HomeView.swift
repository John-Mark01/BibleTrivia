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
    
    @State private var openModal: Bool = false
    
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
                    VStack(alignment: .leading) {
                        Text("Unfinished Quizzes")
                            .applyFont(.medium, size: 20)
                        
                        
                        if !userStore.startedQuizzes.isEmpty {
                            UnfinishedQuizesViewRow(
                                quizes: userStore.startedQuizzes,
                                onChoseQuiz: self.resumeQuiz(_:)
                            )
                        } else {
                            EmptyQuizView()
                        }
                    }
                    
                    //Find New Quizzes
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Find New Quizzes")
                            .applyFont(.medium, size: 20)
                        
                        FindQuizViewRow(quizes: quizStore.allQuizez, isPresented: $openModal)
                        
                    }
                    .padding(.top, 10)
                }
                .navigationTitle("Welcome, \(userStore.user.name)!")
                .navigationBarBackButtonHidden()
                .navigationBarTitleDisplayMode(.large)
                .blur(radius: openModal ? 3 : 0)
                .disabled(openModal)
                .blurTabBar(openModal)
                .applyViewPaddings()
                .applyBackground()
                .applyAccountButton(avatar: Image("Avatars/jacob"), onTap: {
                    router.navigateTo(.account)
                })
            }
            .background(Color.BTBackground)
            
            if openModal {
                if let quiz = quizStore.chosenQuiz {
                    ChooseQuizModal(isPresented: $openModal, quiz: quiz, startQuiz: {
                        quizStore.startQuiz {
                            router.navigateTo(.quizView)
                            openModal = false
                        }
                    }, cancel: {
                        openModal = false
                    })
                    
                }
            }
        }
    }
    
    private func resumeQuiz(_ quiz: StartedQuiz) {
        Task {
            await quizStore.resumeQuiz(quiz.quiz, from: quiz.sessionId)
            print("🟢 Resumin Quiz with name: \(quiz.quiz.name)\n")
            withAnimation(.snappy) {
//                openModal = true //TODO: Add new modal for Resuming a quiz
                router.navigateTo(.quizView)
            }
        }
    }
}

#Preview {
    PreviewEnvironmentView {
        HomeView()
    }
}


import SwiftUI


struct EmptyQuizView: View {
    var body: some View {
        
        VStack(alignment: .center, spacing: 5) {
            Image(systemName: "clock")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(Color.white)
                .symbolEffect(.rotate)
                .padding(.bottom, 8)
            Text("No Started Quizzes Yet")
                .font(.headline)
                .foregroundColor(.white)
            Text("Choose one from down below.")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .padding()
        .background(Color.BTDarkGray)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview("EmptyQuizView") {
    EmptyQuizView()
}
