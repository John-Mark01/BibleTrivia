//
//  QuizSessionWithQuiz.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 24.10.25.
//

import Foundation

// Combined response that contains all payloads
struct CompletedQuizWithSession: Decodable {
    let session: QuizSessionResponse
    let quiz: QuizPayload
    let questions: [QuestionWithAnswers]
}

// Helper struct for nested question + answers
struct QuestionWithAnswers: Decodable {
    let question: QuestionPayload
    let answers: [AnswerPayload]
    
    func toQuestion() -> Question {
        var question = self.question.toQuestion()
        question.answers = self.answers.map { $0.toAnswer()}
        
        return question
    }
}
