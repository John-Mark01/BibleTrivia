//
//  TopicQuizzesView.swift
//  BibleTrivia
//

import SwiftUI

/// The selected topic's new and completed quizzes.
struct TopicQuizzesView: View {
    @Environment(TopicStore.self) private var topicStore

    @State private var selectedQuiz: Quiz?

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: Constants.vStackSpacing) {
                SectionTitle(title: "New")

                if topicStore.topicQuizzes.items.isEmpty && !topicStore.topicQuizzes.isLoading {
                    EmptyStateView(systemImage: "checkmark.seal", message: "You've played every quiz in this topic.")
                } else {
                    QuizListView(quizzes: topicStore.topicQuizzes.items) { quiz in
                        selectedQuiz = quiz
                    } onItemAppear: { quiz in
                        await topicStore.loadMoreTopicQuizzesIfNeeded(after: quiz)
                    }
                }

                if !topicStore.topicCompleted.items.isEmpty {
                    SectionTitle(title: "Completed")
                        .padding(.top, 8)

                    ForEach(topicStore.topicCompleted.items) { attempt in
                        CompletedQuizRow(attempt: attempt)
                            .padding(1)
                            .task { await topicStore.loadMoreTopicCompletedIfNeeded(after: attempt) }
                    }
                }

                if topicStore.topicQuizzes.isLoading || topicStore.topicCompleted.isLoading {
                    PaginationSpinner()
                }
            }
        }
        .refreshable { await topicStore.loadSelectedTopicContent() }
        .task { await topicStore.loadSelectedTopicContent() }
        .navigationTitle(topicStore.selectedTopic?.name ?? "Quizzes")
        .navigationBarTitleDisplayMode(.inline)
        .applyViewPaddings(.horizontal)
        .applyBackground()
        .quizStartModal($selectedQuiz)
    }
}

#Preview {
    let app = AppDependencies.preview()
    app.topicStore.select(SampleData.topics[0])
    return PreviewEnvironment(app: app) {
        TopicQuizzesView()
    }
}
