//
//  AllTopicsView.swift
//  BibleTrivia
//

import SwiftUI

/// Grid of every topic with progress. Shown as the Topics tab and from "See all".
struct AllTopicsView: View {
    @Environment(TopicStore.self) private var topicStore

    @State private var selectedTopic: Topic?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(topicStore.topics.items) { topic in
                    TopicCard(topic: topic, style: .grid)
                        .makeButton(action: { selectedTopic = topic }, addHapticFeedback: true, feedbackStyle: .start)
                        .task { await topicStore.loadMoreTopicsIfNeeded(after: topic) }
                }
            }
            .padding(.horizontal, 3)

            if topicStore.topics.isLoading {
                PaginationSpinner()
            }
        }
        .padding(.bottom, 1)
        .refreshable { await topicStore.loadTopics(reset: true) }
        .task {
            if topicStore.topics.items.isEmpty {
                await topicStore.loadTopics(reset: true)
            }
        }
        .navigationTitle("Topics")
        .navigationBarTitleDisplayMode(.inline)
        .applyViewPaddings()
        .applyBackground()
        .topicModal($selectedTopic)
    }
}

#Preview {
    PreviewEnvironment {
        AllTopicsView()
    }
}
