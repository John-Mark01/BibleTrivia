//
//  CompletedQuizzezViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 13.10.25.
//

import SwiftUI

struct CompletedQuizzezViewRow: View {
    var completedQuiz: CompletedQuiz
    
    private var quizName: String {
        completedQuiz.quiz.name
    }
    
    private var completedAtString: String {
        if let completedAt = completedQuiz.session?.completedAt {
            return completedAt
        }
        
        return "n/a"
    }
    
    private var pointsString: String {
        "\(10) Points" //TODO: Need to update user_sessions to include received points
    }
    
    private var isPassed: Bool {
        if let passed = completedQuiz.session?.passed {
            return passed
        }
        
        return false
    }
    
    var body: some View {
        BTContentBox {
            HStack(alignment: .center, spacing: 12) {
                
                //TODO: Here should be the quiz photo
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 70, height: 72)
                    .foregroundStyle(.lightGray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(quizName)
                        .applyFont(.medium, size: 14, textColor: .BTBlack)
                    
                    Text(completedAtString)
                        .applyFont(.regular, size: 10, textColor: .lightGray)
                    
                    Text(pointsString)
                        .applyFont(.semiBold, size: 16, textColor: Color.init(hex: "6A5ADF"))
                        .padding(.top, 8)
                    
                    Spacer()
                }
                
                Spacer()
                
                Text(isPassed ? "Passed" : "Failed")
                    .applyFont(.regular, size: 14, textColor: .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 3)
                    .background(isPassed ? Color.greenGradient : Color.redGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }
}
