//
//  QuizCard.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 23.10.24.
//


import SwiftUI

struct QuizCard: View {
    
    let quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(quiz.name)
                    .foregroundStyle(Color.BTBlack)
                    .modifier(CustomText(size: 16, font: .semiBold))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Text(quiz.status.stringValue)
                    .foregroundStyle(Color.BTPrimary)
                    .modifier(CustomText(size: 14, font: .medium))
            }
            HStack {
                Text("\(quiz.numberOfQuestions) questions")
                    .modifier(CustomText(size: 14, font: .regular))
                    .foregroundStyle(Color.BTLightGray)
            }
            HStack {
                Text("\(quiz.totalPoints) points")
                    .foregroundStyle(Color.BTPrimary)
                    .modifier(CustomText(size: 16, font: .regular))
                    .padding(.top, 8)
                
                Spacer()
                
            }
            
           
        }
        .padding()
        .background(Color.BTBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.BTStroke, lineWidth: 2)
                .frame(height: 130)
        )
    }
}

