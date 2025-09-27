//
//  TopicCard.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 22.10.24.
//
import SwiftUI

struct TopicCard: View {
    @Binding var topic: Topic
    @State var topicType: TopicCardType = .play
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if topicType == .all {
                Text(topic.status.stringValue)
                    .applyFont(.regular, size: 10, textColor: .white)
            }
            
            HStack {
                Text(topic.name)
                    .applyFont(.semiBold, size: 15)
            }
            HStack {
                Text("\(topic.numberOfQuizes) quizzez")
                    .applyFont(.regular, size: 14, textColor: .BTLightGray)
            }
            
            SimpleLinearProgressView(progress: Int(topic.completenesLevel), goal: topic.numberOfQuizes, progressString: topic.progressString, progressColor: setBackgroundColor())
        }
        .padding()
        .background(setBackgroundColor())
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.BTStroke, lineWidth: 2)
        )
    }
    func setBackgroundColor() -> Color {
        let colors = [
            Color.blueGradient,
            Color.creamGradient,
            Color.greenGradient,
            Color.pinkGradient,
            Color.redGradient]
        switch topicType {
        case .play:
            return Color.BTBackground
        case .all:
            return colors.randomElement()!
        }
    }
    enum TopicCardType: Int, CaseIterable {
        case play = 0
        case all  = 1
    }
}
