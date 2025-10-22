//
//  QuizSessionService.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 30.09.25.
//

import Foundation
import Supabase

final class QuizSessionService {
    private let supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    // MARK: - 1. Start Quiz
    
    /// Call this when user taps "Start Quiz"
    /// Returns the session ID to track this quiz attempt
    func startQuiz(_ quiz: Quiz, userId: UUID) async throws -> Int {
        struct InsertSession: Encodable {
            let user_id: String
            let quiz_id: Int
            let total_questions: Int
            let status: String = "in_progress"
        }
        
        let newSession = InsertSession(
            user_id: userId.uuidString,
            quiz_id: quiz.id,
            total_questions: quiz.questions.count
        )
        
        let response: [QuizSessionResponse] = try await supabaseClient
            .from(Table.sessions)
            .insert(newSession)
            .select()
            .execute()
            .value
        
        guard let session = response.first else {
            throw NSError(domain: "QuizError", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to create quiz session"])
        }
        
        return session.id
    }
    
    // MARK: - 2. Save Quiz Progress
    
    /// Call this when user exits without completing
    /// Saves all answered questions so they can resume later
    func saveQuizProgress(sessionId: Int, quiz: Quiz) async throws {
        let answers = extractAnswers(from: quiz)
        
        guard !answers.isEmpty else {
            // No answers to save
            return
        }
        
        let answersJSON = try JSONEncoder().encode(answers)
        let answersJSONB = String(data: answersJSON, encoding: .utf8) ?? "[]"
        
        let _ = try await supabaseClient
            .rpc("save_quiz_progress", params: [
                "session_id_param": String(sessionId),
                "answers_param": answersJSONB,
                "is_completed": "false"
            ])
            .execute()
    }
    
    // MARK: - 3. Complete Quiz
    
    /// Call this when user completes the quiz
    /// Marks session as completed and calculates final score
    func completeQuiz(sessionId: Int, quiz: Quiz) async throws {
        let answers = extractAnswers(from: quiz)
        let answersJSON = try JSONEncoder().encode(answers)
        let answersJSONB = String(data: answersJSON, encoding: .utf8) ?? "[]"
        
        let _ = try await supabaseClient
            .rpc("save_quiz_progress", params: [
                "session_id_param": String(sessionId),
                "answers_param": answersJSONB,
                "is_completed": "true"
            ])
            .execute()
            .value
    }
    
    // MARK: - 4 Resume Quiz
    
    /// Get in-progress quizzes for the user
    func getInProgressQuizzes(for userId: UUID) async throws -> [QuizSessionResponse] {
        let sessions: [QuizSessionResponse] = try await supabaseClient
            .from(Table.sessions)
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("status", value: "in_progress")
            .order("last_saved_at", ascending: false)
            .execute()
            .value
        
        return sessions
    }
    /// Get completed quizzes for the user
    func getCompletedQuizzes(for userId: UUID) async throws -> [QuizSessionResponse] {
        let sessions: [QuizSessionResponse] = try await supabaseClient
            .from(Table.sessions)
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("status", value: "completed")
            .order("last_saved_at", ascending: false)
            .execute()
            .value
        
        return sessions
    }
    
    /// Resume a specific quiz session
    /// Returns the saved answers to restore quiz state
    func resumeQuizSession(sessionId: Int) async throws -> [SavedAnswer] {
        struct SessionWithAnswers: Codable {
            let answers: [SavedAnswer]
        }
        
        let session: SessionWithAnswers = try await supabaseClient
            .from(Table.sessions)
            .select("answers")
            .eq("id", value: sessionId)
            .single()
            .execute()
            .value
        
        return session.answers
    }
    
    /// Restore quiz state from saved answers
    func restoreQuizState(quiz: inout Quiz, savedAnswers: [SavedAnswer]) {
        // Create a map of question_id -> saved answer
        let answerMap = Dictionary(uniqueKeysWithValues: savedAnswers.map { ($0.questionId, $0) })
        
        // Restore user answers to questions
        for i in 0..<quiz.questions.count {
            let questionId = quiz.questions[i].id
            
            if let savedAnswer = answerMap[questionId] {
                // Find the answer in the question's answers array
                if let answerIndex = quiz.questions[i].answers.firstIndex(where: { $0.id == savedAnswer.answerId }) {
                    quiz.questions[i].answers[answerIndex].isSelected = true
                    quiz.questions[i].userAnswer = quiz.questions[i].answers[answerIndex]
                }
            }
        }
        
        // Update current question index to first unanswered question
        if let firstUnanswered = quiz.questions.firstIndex(where: { $0.userAnswer == nil }) {
            quiz.currentQuestionIndex = firstUnanswered
        } else {
            // All questions answered
            quiz.currentQuestionIndex = quiz.questions.count - 1
        }
    }
    
    // MARK: - Helper Methods
    
    /// Extract answers from Quiz object
    private func extractAnswers(from quiz: Quiz) -> [SavedAnswer] {
        let dateFormatter = ISO8601DateFormatter()
        let now = dateFormatter.string(from: Date())
        
        return quiz.questions.compactMap { question in
            guard let userAnswer = question.userAnswer else {
                return nil // Question not answered
            }
            
            return SavedAnswer(
                questionId: question.id,
                answerId: userAnswer.id,
                isCorrect: userAnswer.isCorrect,
                answeredAt: now
            )
        }
    }
    
//MARK: - Analitycs
    
    // Get total attempts for quiz
    func getQuizAttempts(for userId: UUID, quizId: Int) async throws -> Int {
        let attempts: [QuizSessionResponse] = try await supabaseClient
            .from(Table.sessions)
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("quiz_id", value: quizId)
            .order("attempt_number", ascending: true)
            .execute()
            .value
        
        return attempts.count
    }
    
    // Get best score for a quiz
    func getBestScoreForQuiz(for userId: UUID, quizId: Int) async throws -> Double? {
        struct BestScore: Codable {
            let percentage: Double?
        }
        
        let result: [BestScore] = try await supabaseClient
            .from(Table.sessions)
            .select("percentage")
            .eq("user_id", value: userId.uuidString)
            .eq("quiz_id", value: quizId)
            .eq("status", value: "completed")
            .order("percentage", ascending: false)
            .limit(1)
            .execute()
            .value
        
        return result.first?.percentage
    }
}
