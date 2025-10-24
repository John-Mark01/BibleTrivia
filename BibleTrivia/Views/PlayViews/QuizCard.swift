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
        BTContentBox {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(quiz.name)
                        .applyFont(.semiBold, size: 16)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text(quiz.status.stringValue)
                        .applyFont(.medium, size: 14, textColor: .btPrimary)
                }
                
                Text("\(quiz.numberOfQuestions) questions")
                    .applyFont(.regular, size: 14, textColor: .btLightGray)
                
                Text("\(quiz.totalPoints) points")
                    .applyFont(.regular, size: 16, textColor: .btPrimary)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: 200, maxHeight: 130)
        .frame(minWidth: 180)
    }
}

