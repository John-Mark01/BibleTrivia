//
//  QuizSessionResponse.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 1.10.25.
//

import Foundation

struct QuizSessionResponse: Codable {
    let id: Int
    let userId: String
    let quizId: Int
    let startedAt: String
    let completedAt: String?
    let status: String
    let attemptNumber: Int?
    let percentage: Double?
    let passed: Bool?
    let timeSpent: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case quizId = "quiz_id"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case status
        case attemptNumber = "attempt_number"
        case percentage
        case passed
        case timeSpent = "time_spent_seconds"
    }
}
