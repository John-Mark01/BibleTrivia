//
//  TopicCard.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 22.10.24.
//
import SwiftUI

struct TopicCard: View {
    @Binding var topic: Topic
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(topic.name)
                    .foregroundStyle(Color.BTBlack)
                    .modifier(CustomText(size: 15, font: .questionTitle))
            }
            HStack {
                Text("\(topic.numberOfQuizes) quizzez")
                    .modifier(CustomText(size: 14, font: .label))
                    .foregroundStyle(Color.BTLightGray)
            }
            
            SimpleLinearProgressView(progress: Int(topic.completenesLevel), goal: topic.numberOfQuizes, progressString: topic.progressString)
        }
        .padding()
        .background(Color.BTBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.BTStroke, lineWidth: 2)
        )
    }
}

#Preview {
    @Previewable @State var topic = DummySVM.shared.topics[0]
    TopicCard(topic: $topic)
}
