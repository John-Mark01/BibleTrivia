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
                VStack(alignment: .leading) {
                    Text(quiz.name)
                        .applyFont(.regular, size: 16)

                    Text("\(quiz.numberOfQuestions) questions")
                        .applyFont(.regular, size: 10, textColor: .BTLightGray)
                }
                .padding(1)
                
                Spacer()
                //TODO: Fix this after Cursor
//                ZStack {
//                    CircularProgressView(progress: $quiz.progressValue)
//                        .frame(width: 40, height: 40)
//                    
//                    Text(quiz.progressString)
//                        .modifier(CustomText(size: 10, font: .regular))
//                        .foregroundStyle(Color.BTPrimary)
//                }
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
