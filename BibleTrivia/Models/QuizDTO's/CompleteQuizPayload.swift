//
//  CompleteQuizPayload.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 24.10.25.
//

import Foundation

struct CompleteQuizPayload: Decodable {
    let quiz: QuizPayload
    let questions: [QuestionWithAnswers]
    
    func convertToQuiz() -> Quiz {
        let mappedQuiz = quiz.toQuiz()
        mappedQuiz.questions = questions.map { $0.toQuestion() }
        
        return mappedQuiz
    }
}
