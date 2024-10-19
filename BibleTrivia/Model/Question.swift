//
//  Question.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 12.10.24.
//

import Foundation

struct Question: Equatable {
    
    var id = UUID()
    var text: String = ""
    var explanation: String = ""
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
    
    
    
//    init(text: String, answers: [Answer], explanation: String) {
//        self.id = UUID()
//        self.text = text
//        self.explanation = explanation
//        self.answers = answers
//    }
    
    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.id == rhs.id
    }
}
