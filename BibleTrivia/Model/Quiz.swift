//
//  Quiz.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 12.10.24.
//

import Foundation

@Observable class Quiz {
    let id = UUID()
    var name: String
    var questions: [Question]
    let time: TimeInterval
    var status: QuizStatus = .new
    var difficulty: DifficultyLevel = .newBorn
    
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
        let questionsAnswered = questions.filter({$0.userAnswer != nil})
        let progress = Double(questionsAnswered.count) / Double(numberOfQuestions)
            let percentageFormatter = NumberFormatter()
            percentageFormatter.numberStyle = .percent
            percentageFormatter.maximumFractionDigits = 0
            return percentageFormatter.string(from: NSNumber(value: progress)) ?? "0%"
    }
    var progressValue: Double {
        get {
            return Double(questionNumber) / Double(numberOfQuestions)
        }
        set {
            
        }
    }
    
    var isInReview = false
    var isFinished = false
    
    init(name: String, questions: [Question], time: TimeInterval, status: QuizStatus, difficulty: DifficultyLevel, totalPoints: Int) {
        self.name = name
        self.questions = questions
        self.time = time
        self.status = status
        self.difficulty = difficulty
        self.totalPoints = totalPoints
    }
}

enum QuizStatus: Int {
    case new, started, completed
    
    var stringValue: String {
        switch self {
        case .new:
            return "New"
        case .started:
            return "Started"
        case .completed:
            return "Completed"
        }
    }
}
