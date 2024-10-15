//
//  TopicViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.10.24.
//

import SwiftUI

struct QuizSquareView: View {
    @Binding var quiz: Quiz
    var body: some View {
        VStack(alignment: .leading) {
            Image("Book")
                .padding(.leading, 20)
                .padding()
            HStack {
                VStack {
                    Text(quiz.name)
                        .modifier(CustomText(size: 16, font: .button))
                    Text("\(quiz.numberOfQuestions) questions")
                        .modifier(CustomText(size: 10, font: .label))
                        .foregroundStyle(Color.BTLightGray)

                }
                Spacer()
                
                ZStack {
                    CircularProgressView(progress: quiz.progressValue)
                        .frame(width: 40, height: 40)
                    
                    Text(quiz.progressString)
                        .modifier(CustomText(size: 10, font: .label))
                        .foregroundStyle(Color.BTPrimary)
                }
            }
            .padding(8)
        }
        .background(Color.BTBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.BTStroke, lineWidth: 2)
        )
    
    }
}
