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
