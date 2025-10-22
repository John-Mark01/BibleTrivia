//
//  QuizRectangleView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 23.10.24.
//

import SwiftUI


struct QuizRectangleView: View {
    var quiz: Quiz
    
    var body: some View {
        VStack {
            HStack(spacing: 18) {
                Circle()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.btPrimary)
                    .overlay(
                        Image("Quiz_Pic")
                    )
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(quiz.name)
                            .applyFont(.regular, size: 14)
                        
                        Text("\(quiz.numberOfQuestions) " + "Questions")
                            .applyFont(.regular, size: 10, textColor: .btLightGray)
                        
                    }
                }
                Spacer()
                
                Image("Icon/navigation_arrow")
                    .padding()
            }
        }
        .padding()
        .cornerRadius(16)
        
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.clear)
                .stroke(.btStroke, lineWidth: 2)
        )
    }
}
