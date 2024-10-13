//
//  Quiz.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 12.10.24.
//

import Foundation

struct Quiz {
    let id = UUID()
    var name: String
    let questions: [Question]
    let time: TimeInterval
    let status: QuizStatus
    let difficulty: DifficultyLevel
    
    var totalPoints: Int
    
    var numberOfQuestions: Int {
        return questions.count
    }
    var progressString: String {
        let progress: Double = self.progressValue
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        percentageFormatter.maximumFractionDigits = 0 // For whole percentages
        // or percentageFormatter.maximumFractionDigits = 1 // For one decimal place

        if let formattedProgress = percentageFormatter.string(from: NSNumber(value: progress)) {
            return formattedProgress
        }
        return "0.0"
    }
    var progressValue: Double {
        let totalQuestions = questions.count
        let questionLeft = questions.filter({$0.isChosenAnswer == false})
        let result = Double((totalQuestions / questionLeft.count) / 10)
        return result
    }
}

enum QuizStatus: Int {
    case new, started, completed
}
