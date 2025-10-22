//
//  TopicsViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 22.10.24.
//

import SwiftUI

struct TopicsCaurosel: View {
    var topics: [Topic]
    var onSelect: (Topic) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(topics, id: \.id) { topic in
                    TopicCard(topic: topic, topicType: .play)
                        .frame(width: 180)
                        .makeButton(action: { onSelect(topic)}, addHapticFeedback: true, feedbackStyle: .start)
                }
            }
        }
    }
}
