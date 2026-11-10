//
//  QuizSession.swift
//  BibleTrivia
//

import Foundation

/// One attempt at a quiz by the current user (`user_quiz_sessions` row).
struct QuizSession: Identifiable, Hashable, Sendable, Decodable {
    let id: Int
    let quizId: Int
    let status: Status
    let startedAt: Date
    let completedAt: Date?
    let attemptNumber: Int
    /// Server-graded answers saved so far.
    let answers: [SavedAnswer]
    let totalQuestions: Int
    let correctAnswers: Int
    let percentage: Double?
    let passed: Bool?
    let pointsEarned: Int
    let timeSpentSeconds: Int?

    enum Status: String, Sendable, Decodable {
        case inProgress = "in_progress"
        case completed
        case abandoned
    }
}

struct SavedAnswer: Hashable, Sendable, Decodable {
    let questionId: Int
    let answerId: Int
    let isCorrect: Bool
}

/// What the client sends when saving or completing: which answer was picked
/// for which question. Correctness is never sent.
struct AnswerSelection: Hashable, Sendable, Encodable {
    let questionId: Int
    let answerId: Int

    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case answerId = "answer_id"
    }
}

/// A session together with its full quiz (in-progress or completed).
struct QuizAttempt: Identifiable, Hashable, Sendable, Decodable {
    let session: QuizSession
    let quiz: Quiz

    var id: Int { session.id }

    /// Fraction of questions answered, 0...1.
    var progress: Double {
        guard quiz.numberOfQuestions > 0 else { return 0 }
        return Double(session.answers.count) / Double(quiz.numberOfQuestions)
    }
}

/// Result of `complete_quiz_session`.
struct QuizCompletion: Hashable, Sendable, Decodable {
    let session: QuizSession
    let totalPoints: Int
    let level: UserLevel
    let leveledUp: Bool
}

struct Streak: Hashable, Sendable, Decodable {
    let currentStreak: Int
    let longestStreak: Int
}
