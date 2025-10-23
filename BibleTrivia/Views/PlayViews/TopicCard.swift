//
//  TopicCard.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 22.10.24.
//
import SwiftUI

struct TopicCard: View {
    var topic: Topic
    var topicType: TopicCardType = .play
    
    var body: some View {
        BTContentBox {
            VStack(alignment: .leading, spacing: 8) {
                if topicType == .all {
                    Text(topic.status.stringValue)
                        .applyFont(.regular, size: 10, textColor: .white)
                }
                
                Text(topic.name)
                    .applyFont(.semiBold, size: 15)
                
                Text("\(topic.numberOfQuizes) quizzez")
                    .applyFont(.regular, size: 14, textColor: .btLightGray)
                
                Text(topic.progressString)
                    .applyFont(.regular, size: 12, textColor: .btBlack)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.bottom, -4)
                
                LinearProgressView(
                    height: 14,
                    progress: topic.playedQuizzes.count,
                    goal: topic.numberOfQuizes,
                    showPercentage: false,
                )
            }
        }
        .frame(maxWidth: 200, maxHeight: 130)
    }
    func setBackgroundColor() -> Color {
        let colors: [Color] = [
            .blueGradient,
            .creamGradient,
            .greenGradient,
            .pinkGradient,
            .redGradient]
        switch topicType {
        case .play:
            return .white
        case .all:
            return colors.randomElement()!
        }
    }
    enum TopicCardType: Int, CaseIterable {
        case play = 0
        case all  = 1
    }
}

#Preview {
    VStack {
        TopicCard(topic: .init(id: 1, name: "Topic Name"), topicType: .play)
    }
    .applyViewPaddings()
    .applyBackground()
}
