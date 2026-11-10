//
//  PlayView.swift
//  BibleTrivia
//

import SwiftUI

struct PlayView: View {
    @Environment(Router.self) private var router
    @Environment(QuizStore.self) private var quizStore
    @Environment(TopicStore.self) private var topicStore
    @Environment(UserStore.self) private var userStore

    @State private var selectedQuiz: Quiz?
    @State private var selectedTopic: Topic?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                QuizUpdateView(
                    activeAttempt: userStore.inProgress.first,
                    onContinue: resume,
                    onStartNew: { selectedQuiz = quizStore.available.items.first }
                )

                SectionTitle(title: "Choose a Topic")
                    .setTextButton("See all") { router.navigate(to: .allTopics) }

                TopicsCarousel(topics: topicStore.topics.items) { selectedTopic = $0 }

                SectionTitle(title: "Quick Quiz")

                if quizStore.available.items.isEmpty && !quizStore.available.isLoading {
                    EmptyStateView(systemImage: "checkmark.seal", message: "No new quizzes right now.")
                } else {
                    QuizzesCarousel(quizzes: quizStore.available.items) { selectedQuiz = $0 }
                }
            }
            .applyViewPaddings()
            .padding(.bottom, 100) // clear the floating tab bar
        }
        .refreshable {
            async let quizzes: Void = quizStore.loadAvailable(reset: true)
            async let topics: Void = topicStore.loadTopics(reset: true)
            _ = await (quizzes, topics)
        }
        .navigationTitle("Play")
        .navigationBarTitleDisplayMode(.inline)
        .applyBackground()
        .applyAccountButton(avatar: Image("Avatars/jacob")) {
            router.navigate(to: .account)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    Image("star")
                    Text("\(userStore.profile?.totalPoints ?? 0)")
                        .applyFont(.regular, size: 18)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(userStore.profile?.totalPoints ?? 0) points")
            }
        }
        .quizStartModal($selectedQuiz)
        .topicModal($selectedTopic)
    }

    private func resume(_ attempt: QuizAttempt) {
        quizStore.resume(attempt)
        router.navigate(to: .quiz)
    }
}

#Preview {
    PreviewEnvironment {
        PlayView()
    }
}
