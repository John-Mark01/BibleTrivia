//
//  ChooseTopicModal.swift
//  BibleTrivia
//

import SwiftUI

struct ChooseTopicModal: View {
    let topic: Topic
    let goToQuizzes: () -> Void
    let cancel: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.1)
                .onTapGesture(perform: cancel)

            VStack(alignment: .center, spacing: 10) {
                Text(topic.name)
                    .applyFont(.medium, size: 20)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                VStack(spacing: 22) {
                    InfoRow(image: "medal-star", title: "Status:", value: topic.status.title)
                    InfoRow(image: "task-square", title: "Completed:", value: "\(topic.completedQuizCount)/\(topic.quizCount)")
                    InfoRow(image: "cup", title: "Points:", value: "\(topic.earnedPoints)/\(topic.totalPoints)")
                    LinearProgressView(progress: topic.progress)
                }

                Spacer()

                VStack {
                    Button("View Quizzes", action: goToQuizzes)
                        .buttonStyle(.primary)

                    Button("Close", action: cancel)
                        .buttonStyle(.secondary)
                }
            }
            .padding(25)
            .background(.btBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .fixedSize(horizontal: false, vertical: true)
            .padding(30)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Presentation

/// Shows `ChooseTopicModal` while `topic` is non-nil and opens the topic's
/// quizzes on confirmation.
private struct TopicModal: ViewModifier {
    @Binding var topic: Topic?
    @Environment(TopicStore.self) private var topicStore
    @Environment(Router.self) private var router

    func body(content: Content) -> some View {
        content
            .blur(radius: topic != nil ? 3 : 0)
            .disabled(topic != nil)
            .blurTabBar(topic != nil)
            .overlay {
                if let topic {
                    ChooseTopicModal(
                        topic: topic,
                        goToQuizzes: {
                            topicStore.select(topic)
                            self.topic = nil
                            router.navigate(to: .topicQuizzes)
                        },
                        cancel: { self.topic = nil }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .animation(.snappy, value: topic?.id)
    }
}

extension View {
    func topicModal(_ topic: Binding<Topic?>) -> some View {
        modifier(TopicModal(topic: topic))
    }
}

#Preview {
    ChooseTopicModal(topic: SampleData.topics[0], goToQuizzes: {}, cancel: {})
}
