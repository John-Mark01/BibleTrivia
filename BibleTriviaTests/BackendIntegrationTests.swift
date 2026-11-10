//
//  BackendIntegrationTests.swift
//  BibleTriviaTests
//
//  Runs the real API against the Supabase project configured for Debug builds
//  (the dev project). Skipped unless credentials are provided:
//
//    TEST_RUNNER_BT_EMAIL=… TEST_RUNNER_BT_PASSWORD=… xcodebuild test …
//
//  Set TEST_RUNNER_BT_COMPLETE=1 to also complete a quiz. That permanently
//  uses up one quiz for the test account, so it's off by default.
//

import Foundation
import Testing
@testable import BibleTrivia

@MainActor
@Suite(.enabled(if: ProcessInfo.processInfo.environment["BT_EMAIL"] != nil, "Set BT_EMAIL / BT_PASSWORD to run"))
struct BackendIntegrationTests {

    @Test func fullQuizFlowAgainstDevBackend() async throws {
        let env = ProcessInfo.processInfo.environment
        let app = AppDependencies.live()
        let api = app.api

        await app.auth.signIn(email: try #require(env["BT_EMAIL"]), password: try #require(env["BT_PASSWORD"]))
        #expect(app.alerts.current == nil, "Sign-in failed: \(String(describing: app.alerts.current?.message))")

        let streak = try await api.checkIn(timeZone: TimeZone.current.identifier)
        #expect(streak.currentStreak >= 1)

        let profile = try await api.fetchProfile()
        #expect(!profile.name.isEmpty)

        let topics = try await api.fetchTopics(limit: 2, offset: 0)
        #expect(topics.count <= 2)

        let available = try await api.fetchAvailableQuizzes(topicId: nil, limit: 20, offset: 0)
        let quiz = try #require(available.first, "Test account has no quizzes left to play")
        let byTopic = try await api.fetchAvailableQuizzes(topicId: quiz.topicId, limit: 20, offset: 0)
        #expect(byTopic.allSatisfy { $0.topicId == quiz.topicId })

        // Start is idempotent.
        let session = try await api.startSession(quizId: quiz.id)
        let again = try await api.startSession(quizId: quiz.id)
        #expect(session.id == again.id)
        #expect(session.status == .inProgress)

        // Server grades answers; a mismatched pair is ignored.
        let first = quiz.questions[0]
        let saved = try await api.saveProgress(sessionId: session.id, answers: [
            AnswerSelection(questionId: first.id, answerId: first.answers[0].id),
            AnswerSelection(questionId: first.id + 999_999, answerId: first.answers[0].id),
        ])
        #expect(saved.answers.count == 1)
        #expect(saved.answers.first?.isCorrect == first.answers[0].isCorrect)

        let inProgress = try await api.fetchAttempts(status: .inProgress, topicId: nil, limit: 50, offset: 0)
        #expect(inProgress.contains { $0.session.id == session.id })

        if env["BT_COMPLETE"] == "1" {
            let picks = quiz.questions.compactMap { q in q.correctAnswer.map { AnswerSelection(questionId: q.id, answerId: $0.id) } }
            let result = try await api.completeSession(sessionId: session.id, answers: picks)
            #expect(result.session.status == .completed)
            #expect(result.session.passed == true)
            #expect(result.session.pointsEarned == quiz.totalPoints)
            let completed = try await api.fetchAttempts(status: .completed, topicId: quiz.topicId, limit: 5, offset: 0)
            #expect(completed.contains { $0.session.id == session.id })
        } else {
            try await api.abandonSession(sessionId: session.id)
            let after = try await api.fetchAttempts(status: .inProgress, topicId: nil, limit: 50, offset: 0)
            #expect(!after.contains { $0.session.id == session.id })
        }

        // Errors map to AppError.
        await #expect(throws: AppError.self) {
            try await api.saveProgress(sessionId: -1, answers: [])
        }

        await app.auth.signOut()
    }
}
