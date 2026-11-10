//
//  DecodingTests.swift
//  BibleTriviaTests
//
//  Payloads below are real responses captured from the dev database's RPCs.
//

import Foundation
import Testing
@testable import BibleTrivia

struct DecodingTests {

    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder.api.decode(T.self, from: Data(json.utf8))
    }

    @Test func decodesQuizFromGetAvailableQuizzes() throws {
        let quizzes = try decode([Quiz].self, """
        [{"id": 1, "name": "In the Beginning", "topic_id": 1, "difficulty": 0, "total_points": 50,
          "time_to_complete": 2, "questions": [
            {"id": 1, "text": "On which day did God create light", "explanation": "Genesis 1:3-5",
             "answers": [{"id": 1, "text": "The first day", "is_correct": true},
                         {"id": 2, "text": "The third day", "is_correct": false}]}]}]
        """)
        let quiz = try #require(quizzes.first)
        #expect(quiz.topicId == 1)
        #expect(quiz.difficulty == .newBorn)
        #expect(quiz.timeToComplete == 2)
        #expect(quiz.questions.first?.correctAnswer?.id == 1)
    }

    @Test func decodesCompletion() throws {
        let completion = try decode(QuizCompletion.self, """
        {"level": 0, "session": {"id": 1, "passed": false, "status": "completed", "answers": [
            {"answer_id": 1, "is_correct": true, "answered_at": "2026-11-10T15:35:13.179548+00:00", "question_id": 1}],
          "quiz_id": 1, "percentage": 66.67, "started_at": "2026-11-10T15:35:13.179548+00:00",
          "completed_at": "2026-11-10T15:35:14.2+00:00", "points_earned": 33, "attempt_number": 1,
          "correct_answers": 2, "total_questions": 3, "time_spent_seconds": 0},
         "leveled_up": false, "total_points": 33}
        """)
        #expect(completion.totalPoints == 33)
        #expect(completion.level == .newBorn)
        #expect(completion.session.status == .completed)
        #expect(completion.session.percentage == 66.67)
        #expect(completion.session.answers.first?.isCorrect == true)
        #expect(completion.session.completedAt != nil)
    }

    @Test func decodesInProgressSessionWithNulls() throws {
        let session = try decode(QuizSession.self, """
        {"id": 2, "passed": null, "status": "in_progress", "answers": [], "quiz_id": 2, "percentage": null,
         "started_at": "2026-11-10T15:35:13+00:00", "completed_at": null, "points_earned": 0,
         "attempt_number": 1, "correct_answers": 0, "total_questions": 3, "time_spent_seconds": null}
        """)
        #expect(session.status == .inProgress)
        #expect(session.passed == nil)
        #expect(session.completedAt == nil)
    }

    @Test func decodesProfile() throws {
        let profile = try decode(UserProfile.self, """
        {"id": "11111111-1111-1111-1111-111111111111", "age": 30, "name": "Test User",
         "email": "tester@example.com", "level": 0, "payment_plan": 0, "total_points": 33,
         "joined_at": "2026-11-10T15:35:13.179548+00:00", "current_streak": 1, "longest_streak": 1,
         "completed_quizzes": 1, "in_progress_quizzes": 0, "next_level_min_points": 100,
         "current_level_min_points": 0}
        """)
        #expect(profile.firstName == "Test")
        #expect(profile.levelProgress == 0.33)
        #expect(profile.level.next == .churchVolunteer)
    }

    @Test func decodesProfileAtMaxLevel() throws {
        let profile = try decode(UserProfile.self, """
        {"id": "11111111-1111-1111-1111-111111111111", "age": 30, "name": "Max", "email": null,
         "level": 4, "payment_plan": 2, "total_points": 2000, "joined_at": "2026-11-10T15:35:13Z",
         "current_streak": 0, "longest_streak": 9, "completed_quizzes": 40, "in_progress_quizzes": 0,
         "next_level_min_points": null, "current_level_min_points": 1500}
        """)
        #expect(profile.level == .seniorPastor)
        #expect(profile.nextLevelMinPoints == nil)
        #expect(profile.levelProgress == 1)
        #expect(profile.paymentPlan == .premium)
    }

    @Test func decodesTopics() throws {
        let topics = try decode([Topic].self, """
        [{"id": 1, "name": "Genesis", "quiz_count": 2, "total_points": 110, "earned_points": 33, "completed_quiz_count": 1},
         {"id": 9, "name": "Empty", "quiz_count": 0, "total_points": 0, "earned_points": 0, "completed_quiz_count": 0}]
        """)
        #expect(topics[0].progress == 0.5)
        #expect(topics[0].status == .inProgress)
        #expect(topics[1].progress == 0)
        #expect(topics[1].status == .new)
    }

    @Test func unknownEnumValuesFallBack() throws {
        let quiz = try decode(Quiz.self, """
        {"id": 1, "name": "x", "topic_id": 1, "difficulty": 99, "total_points": 0, "time_to_complete": 1, "questions": []}
        """)
        #expect(quiz.difficulty == .newBorn)
    }

    @Test func encodesAnswerSelectionsInSnakeCase() throws {
        let data = try JSONEncoder().encode([AnswerSelection(questionId: 4, answerId: 13)])
        #expect(String(decoding: data, as: UTF8.self) == #"[{"question_id":4,"answer_id":13}]"#)
    }
}

struct PostgresDateTests {
    @Test(arguments: [
        "2026-11-10T15:35:13.179548+00:00",
        "2026-11-10T15:35:13.1+00:00",
        "2026-11-10T15:35:13+00:00",
        "2026-11-10T15:35:13Z",
        "2026-11-10T17:35:13.179548+02:00",
    ])
    func parsesPostgresTimestamps(_ string: String) throws {
        let date = try #require(PostgresDate.parse(string))
        let seconds = Calendar(identifier: .gregorian).dateComponents(in: .gmt, from: date)
        #expect(seconds.hour == 15)
        #expect(seconds.minute == 35)
        #expect(seconds.second == 13)
    }

    @Test func rejectsGarbage() {
        #expect(PostgresDate.parse("yesterday") == nil)
    }
}
