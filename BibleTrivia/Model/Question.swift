//
//  Question.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 12.10.24.
//

import Foundation

struct Question {
    let question: String
    let explanation: String
    let answers: [Answer]
    
    var isChosenAnswer: Bool {
        if answers.contains(where: { answer in
            answer.isSelected
        }) {
            return true
        } else {
            return false
        }
    }
    var chosenAnswer: Answer? {
        if let selectedAnswer = answers.first(where: { $0.isSelected }) {
            return selectedAnswer
        }
        return nil
    }
    
    var isSelectedCorrect: Bool {
        if let answerIsCorret = answers.first(where: {$0.isSelected && $0.isSelected}) {
            return true
        } else {
            return false
        }
    }
}
