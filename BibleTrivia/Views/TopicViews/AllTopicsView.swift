//
//  AllTopicsView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 7.11.24.
//

import SwiftUI

struct AllTopicsScreen: View {
    @Environment(TopicStore.self) private var topicStore
    
    @State private var isPaginating: Bool = true
    @State private var openTopicModal: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    
                    //Topics grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                        ForEach(Array(topicStore.allTopics.enumerated()), id: \.element.id) { index, topic in
                            TopicCard(topic: topic, topicType: .all)
                                .onTapGesture { selectTopic(topic) }
                                .task {
                                    if index == topicStore.allTopics.count - 1 {
                                        isPaginating = true
                                        await topicStore.getTopicsForPagination(
                                            limit: 5,
                                            offset: topicStore.allTopics.count
                                        )
                                        isPaginating = false
                                    }
                                }
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
                .applyViewPaddings(.vertical)
                .padding(.horizontal, 3)
            }
            .applyViewPaddings(.horizontal)
            .applyBackground()
            .navigationTitle("Topics")
            .navigationBarTitleDisplayMode(.inline)
            .blur(radius: openTopicModal ? 3 : 0)
            .disabled(openTopicModal)
            
            // Modal
            Group {
                if openTopicModal {
                    ChooseTopicModal(
                        topic: topicStore.currentTopic,
                        goToQuizez: {
                            //                            showAllTopics = true
                            //TODO: Navigate to all topics screen
                        }, cancel: {
                            topicStore.unselectTopic()
                            openTopicModal = false
                        }
                    )
                }
            }
            .zIndex(999)
        }
    }
    
    private func selectTopic(_ topic: Topic) {
        withAnimation {
            topicStore.selectTopic(topic)
            openTopicModal = true
        }
    }
}

#Preview {
    PreviewEnvironmentView {
        AllTopicsScreen()
    }
}

