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
    var questions: [Question]
    let time: TimeInterval
    var status: QuizStatus
    let difficulty: DifficultyLevel
    
    var currentQuestionIndex: Int = 0
    var totalPoints: Int
    
    var numberOfQuestions: Int {
        return questions.count
    }
    
    var currentQuestion: Question {
        
        get {
            return questions[currentQuestionIndex]
        }
        set {
            return questions[currentQuestionIndex] = newValue
        }
    }
    
    var questionNumber: Int {
        get {
            return currentQuestionIndex
        }
        set {
           
        }
    }
    
    var isLastQuestion: Bool {
        if currentQuestion == questions.last {
            return true
        }
        return false
    }
    
    var userPassedTheQuiz: Bool {
        return questions.allSatisfy { question in
            question.userAnswer?.isCorrect == true
        }
    }
    
    
    var progressString: String {
        let progress = Double(questionNumber) / Double(numberOfQuestions)
            let percentageFormatter = NumberFormatter()
            percentageFormatter.numberStyle = .percent
            percentageFormatter.maximumFractionDigits = 0
            return percentageFormatter.string(from: NSNumber(value: progress)) ?? "0%"
    }
    var progressValue: Double {
        return Double(questionNumber) / Double(numberOfQuestions)
    }
    
}

enum QuizStatus: Int {
    case new, started, completed
}
