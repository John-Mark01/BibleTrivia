//
//  HomeView.swift
//  BibleTrivia
//

import SwiftUI

struct HomeView: View {
    @Environment(Router.self) private var router
    @Environment(UserStore.self) private var userStore
    @Environment(QuizStore.self) private var quizStore

    @State private var selectedQuiz: Quiz?

    private var profile: UserProfile? { userStore.profile }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    StatBadge(style: ScoreButton(score: "\(profile?.totalPoints ?? 0)"))
                        .accessibilityLabel("Score: \(profile?.totalPoints ?? 0)")
                    StatBadge(style: StreakButton(width: 123, streak: "\(profile?.currentStreak ?? 0)"))
                        .accessibilityLabel("\(profile?.currentStreak ?? 0) day streak")
                }

                if !userStore.inProgress.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Unfinished Quizzes")
                            .applyFont(.medium, size: 20)

                        UnfinishedQuizzesRow(attempts: userStore.inProgress, onSelect: resume)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Find New Quizzes")
                        .applyFont(.medium, size: 20)

                    if quizStore.available.items.isEmpty && !quizStore.available.isLoading {
                        EmptyStateView(
                            systemImage: "checkmark.seal",
                            message: "You've played every quiz. New ones are on the way!"
                        )
                    } else {
                        QuizListView(quizzes: quizStore.available.items) { quiz in
                            selectedQuiz = quiz
                        } onItemAppear: { quiz in
                            await quizStore.loadMoreAvailableIfNeeded(after: quiz)
                        }
                    }
                }
                .padding(.top, 10)
            }
            .applyViewPaddings()
            .padding(.bottom, 100) // clear the floating tab bar
        }
        .refreshable {
            async let quizzes: Void = quizStore.loadAvailable(reset: true)
            async let profile: Void = userStore.refreshProfile()
            _ = await (quizzes, profile)
        }
        .navigationTitle("Welcome, \(profile?.firstName ?? "friend")!")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden()
        .applyBackground()
        .applyAccountButton(avatar: Image("Avatars/jacob")) {
            router.navigate(to: .account)
        }
        .quizStartModal($selectedQuiz)
    }

    private func resume(_ attempt: QuizAttempt) {
        quizStore.resume(attempt)
        router.navigate(to: .quiz)
    }
}

/// Non-interactive display of a `ScoreButton`/`StreakButton` style.
private struct StatBadge<Style: ButtonStyle>: View {
    let style: Style

    var body: some View {
        Button("") {}
            .buttonStyle(style)
            .allowsHitTesting(false)
    }
}

#Preview {
    PreviewEnvironment {
        HomeView()
    }
}
