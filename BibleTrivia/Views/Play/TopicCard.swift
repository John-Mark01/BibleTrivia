//
//  TopicCard.swift
//  BibleTrivia
//

import SwiftUI

struct TopicCard: View {
    let topic: Topic
    var style: Style = .compact

    enum Style {
        /// White card used in the Play carousel.
        case compact
        /// Coloured card with status, used in the topics grid.
        case grid
    }

    var body: some View {
        BTContentBox(background: background) {
            VStack(alignment: .leading, spacing: 8) {
                if style == .grid {
                    Text(topic.status.title)
                        .applyFont(.regular, size: 10, textColor: .white)
                }

                Text(topic.name)
                    .applyFont(.semiBold, size: 15)
                    .lineLimit(2)

                Text("\(topic.quizCount) quizzes")
                    .applyFont(.regular, size: 14, textColor: .btLightGray)

                Text(topic.progress, format: .percent.precision(.fractionLength(0)))
                    .applyFont(.regular, size: 12, textColor: .btBlack)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.bottom, -4)

                LinearProgressView(progress: topic.progress, height: 14, showPercentage: false)
            }
        }
        .frame(minWidth: 180, maxWidth: 200, maxHeight: 130)
    }

    /// Stable per-topic colour (previously random on every redraw).
    private var background: Color {
        guard style == .grid else { return .white }
        let palette: [Color] = [.blueGradient, .creamGradient, .greenGradient, .pinkGradient, .redGradient]
        return palette[abs(topic.id) % palette.count]
    }
}

#Preview {
    HStack {
        TopicCard(topic: SampleData.topics[0], style: .grid)
        TopicCard(topic: SampleData.topics[1])
    }
    .applyViewPaddings()
    .applyBackground()
}
