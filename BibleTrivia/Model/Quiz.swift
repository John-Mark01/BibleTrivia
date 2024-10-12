//
//  Quiz.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 12.10.24.
//

import Foundation

struct Quiz {
    let name: String
    let explanation: String
    let questions: [Question]
    let time: TimeInterval
    let status: QuizStatus
    let difficulty: DifficultyLevel
    
    var totalPoints: Int
    
    var numberOfQuestions: Int {
        return questions.count
    }
    var chosenAnswer: Question {
        if let selectedAnswer = questions.first(where: { $0.isSelected }) {
            return selectedAnswer
        }
    }
}

enum QuizStatus: Int {
    case new, started, completed
}
