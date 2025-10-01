//
//  StartedQuiz.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 1.10.25.
//

import Foundation

struct StartedQuiz: Identifiable {
    let sessionId: Int
    let quiz: Quiz
    var id: Int { quiz.id }
}

struct CompletedQuiz: Identifiable {
    let sessionId: Int
    let quiz: Quiz
    var id: Int { quiz.id }
}
