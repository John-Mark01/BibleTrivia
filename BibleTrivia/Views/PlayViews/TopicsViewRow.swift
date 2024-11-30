//
//  TopicsViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 22.10.24.
//

import SwiftUI

struct TopicsViewRow: View {
    @Environment(QuizStore.self) var quizStore
    @State var topics: [Topic]
    @Binding var isPresented: Bool
    @State private var goToTopic: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach($topics, id: \.id) { topic in
                        Button(action: {
                            print("I click on starting: \(topic.name.wrappedValue) quiz")
                            quizStore.chosenTopic = topic.wrappedValue
                            withAnimation(.snappy) {
                                isPresented = true
                            }
                        }) {
                            TopicCard(topic: topic, topicType: .play)
                                .frame(width: 180)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    TopicsViewRow(topics: DummySVM.shared.topics, isPresented: .constant(false))
}

