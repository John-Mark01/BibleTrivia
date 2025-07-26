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
                    .applyFont(.semiBold, size: 16)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Text(quiz.status.stringValue)
                    .applyFont(.medium, size: 14, textColor: .BTPrimary)
            }
            HStack {
                Text("\(quiz.numberOfQuestions) questions")
                    .applyFont(.regular, size: 14, textColor: .BTLightGray)
            }
            HStack {
                Text("\(quiz.totalPoints) points")
                    .applyFont(.regular, size: 16, textColor: .BTPrimary)
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

