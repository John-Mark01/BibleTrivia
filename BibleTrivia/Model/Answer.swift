//
//  Answer.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 13.10.24.
//

import Foundation

struct Answer: Codable {
    var id: Int
    var text: String
    var questionId: Int
    var isCorrect: Bool
    var isSelected: Bool = false
    
    init(id: Int, text: String, questionId: Int, isCorrect: Bool) {
        self.id = id
        self.text = text
        self.questionId = questionId
        self.isCorrect = isCorrect
    }
}

//MARK: Server request parsing
struct AnswerPayload: Decodable {
    let id: Int
    let text: String
    var questionId: Int
    let isCorrect: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case text = "name"
        case questionId
        case isCorrect
    }
}

