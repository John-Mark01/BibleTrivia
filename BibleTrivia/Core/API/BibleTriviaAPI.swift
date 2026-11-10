//
//  BibleTriviaAPI.swift
//  BibleTrivia
//

import Foundation

/// Everything the app reads from or writes to the backend, apart from auth.
///
/// Every call maps to one Postgres RPC defined in
/// `supabase/migrations/*_v1_backend.sql`. The backend derives the user from the
/// auth token; no call takes a user id.
protocol BibleTriviaAPI: Sendable {
    // Profile
    func checkIn(timeZone: String) async throws -> Streak
    func fetchProfile() async throws -> UserProfile
    func updateProfile(name: String, age: Int) async throws
    func deleteAccount() async throws

    // Content
    func fetchTopics(limit: Int, offset: Int) async throws -> [Topic]
    func fetchAvailableQuizzes(topicId: Int?, limit: Int, offset: Int) async throws -> [Quiz]

    // Sessions
    func fetchAttempts(status: QuizSession.Status, topicId: Int?, limit: Int, offset: Int) async throws -> [QuizAttempt]
    func startSession(quizId: Int) async throws -> QuizSession
    func saveProgress(sessionId: Int, answers: [AnswerSelection]) async throws -> QuizSession
    func completeSession(sessionId: Int, answers: [AnswerSelection]) async throws -> QuizCompletion
    func abandonSession(sessionId: Int) async throws
}
