//
//  TopicsCarousel.swift
//  BibleTrivia
//

import SwiftUI

struct TopicsCarousel: View {
    let topics: [Topic]
    let onSelect: (Topic) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(topics) { topic in
                    TopicCard(topic: topic, style: .compact)
                        .makeButton(action: { onSelect(topic) }, addHapticFeedback: true, feedbackStyle: .start)
                }
            }
            .padding(1)
        }
    }
}
