//
//  SavedAnswer.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 1.10.25.
//

import Foundation

struct SavedAnswer: Codable {
    let questionId: Int
    let answerId: Int
    let isCorrect: Bool
    let answeredAt: String
    
    private enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case answerId = "answer_id"
        case isCorrect = "is_correct"
        case answeredAt = "answered_at"
    }
}
