//
//  Question.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 12.10.24.
//

import Foundation

struct Question: Equatable {
    
    var id = UUID()
    var question: String = ""
    var explanation: String = ""
    var answers: [Answer] = []
    
    
    init(text: String, answers: [Answer], explanation: String) {
        self.id = UUID()
        self.question = text
        self.explanation = explanation
        self.answers = answers
    }
    
    private var selectedAnswerIndex: Int?
    
    var isAnswerSelected: Bool {
        return selectedAnswerIndex != nil
    }
    
    var chosenAnswer: Answer? {
        guard let index = selectedAnswerIndex else { return nil }
        return answers[index]
    }
    
    var isSelectedCorrect: Bool {
        return chosenAnswer?.isCorrect ?? false
    }
    
    mutating func selectAnswer(at index: Int) {
        guard index >= 0 && index < answers.count else { return }
        selectedAnswerIndex = index
        answers[index].isSelected = true
    }
    
    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.id == rhs.id
    }
}
