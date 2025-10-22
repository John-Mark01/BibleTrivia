//
//  TopicViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.10.24.
//

import SwiftUI

struct QuizSquareView: View {
    var quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading) {
            Image("Icon/book")
                .padding(.leading, 20)
                .padding()
            HStack {
                VStack(alignment: .leading) {
                    Text(quiz.name)
                        .applyFont(.regular, size: 16)

                    Text("\(quiz.numberOfQuestions) questions")
                        .applyFont(.regular, size: 10, textColor: .btLightGray)
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
//                        .foregroundStyle(.btPrimary)
//                }
            }
            .padding(8)
        }
        .background(.btBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.btStroke, lineWidth: 2)
        )
    
    }
}
