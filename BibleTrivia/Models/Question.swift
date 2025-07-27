//
//  Question.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 12.10.24.
//

import Foundation

struct Question: Equatable, Codable {
    
    var id: Int = 0
    var text: String = ""
    var explanation: String = ""
    var quizId: Int = 0
    var answers: [Answer] = []
    var userAnswer: Answer?
    
    var hasSelectedAnswer: Bool {
        if answers.contains(where: {$0.isSelected}) {
            return true
        }
        return false
    }
    
    var userAnswerIsCorrect: Bool {
        if let answer = userAnswer {
            if answer.isCorrect {
                return true
            }
        }
        return false
    }
    
    func getAnswerABC(index: Int) -> String {
        switch index {
        case 0:
            return "A"
        case 1:
            return "B"
        case 2:
            return "C"
        case 3:
            return "D"
        default:
            return "A"
        }
    }
    
    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(id: Int, text: String, explaination: String, quizId: Int) {
        self.id = id
        self.text = text
        self.explanation = explaination
        self.quizId = quizId
    }
    // Will be deleted
    init(text: String, explanation: String, answers: [Answer]) {
        self.text = text
        self.explanation = explanation
        self.answers = answers
    }
    
    init(text: String, explanation: String, answers: [Answer], userAnswer: Answer?) {
        self.text = text
        self.explanation = explanation
        self.answers = answers
        self.userAnswer = userAnswer
    }
   
}

//MARK: Server request parsing
struct QuestionPayload: Decodable {
    let id: Int
    let text: String
    let explaination: String?
    let quizId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case explaination
        case quizId /*= "quiz_id"*/
    }
}
