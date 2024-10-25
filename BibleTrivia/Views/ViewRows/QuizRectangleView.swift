//
//  QuizRectangleView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 23.10.24.
//

import SwiftUI


struct QuizRectangleView: View {
    @Binding var quiz: Quiz
    
    var body: some View {
        VStack {
            HStack(spacing: 18) {
                Circle()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(Color.BTPrimary)
                    .overlay(
                        Image("Quiz_Pic")
                    )
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(quiz.name)
                            .modifier(CustomText(size: 14, font: .regular))
                            .foregroundStyle(Color.BTBlack)
                        
                        Text("\(quiz.numberOfQuestions) " + "Questions")
                            .modifier(CustomText(size: 10, font: .regular))
                            .foregroundStyle(Color.BTLightGray)
                        
                    }
                }
                Spacer()
                
                Image("Go_Arrow")
                    .padding()
            }
        }
        .padding()
        .cornerRadius(16)
        
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.clear)
                .stroke(Color.BTStroke, lineWidth: 2)
        )
    }
}
