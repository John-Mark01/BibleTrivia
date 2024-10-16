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
        return questions[currentQuestionIndex]
    }
    
    var questionNumber: Int {
        return currentQuestionIndex + 1
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
    
    var isCompleted: Bool {
        return status == .completed || currentQuestionIndex == questions.count - 1
    }
    
    mutating func startQuiz() {
        status = .started
        currentQuestionIndex = 0
        totalPoints = 0
    }
    
    mutating func selectAnswer(_ answerIndex: Int) {
        questions[currentQuestionIndex].selectAnswer(at: answerIndex)
        if questions[currentQuestionIndex].isSelectedCorrect {
            totalPoints += 1
        }
    }
    
    mutating func moveToNextQuestion() -> Bool {
        guard currentQuestionIndex < questions.count - 1 else {
            status = .completed
            return false
        }
        currentQuestionIndex += 1
        return true
    }
}

enum QuizStatus: Int {
    case new, started, completed
}
