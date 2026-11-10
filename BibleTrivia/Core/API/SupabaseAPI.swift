//
//  SupabaseAPI.swift
//  BibleTrivia
//

import Foundation
import Supabase

/// Live `BibleTriviaAPI` backed by Supabase RPCs.
struct SupabaseAPI: BibleTriviaAPI {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: Profile

    func checkIn(timeZone: String) async throws -> Streak {
        try await call("check_in", ["p_time_zone": timeZone])
    }

    func fetchProfile() async throws -> UserProfile {
        try await call("get_my_profile")
    }

    func updateProfile(name: String, age: Int) async throws {
        struct Update: Encodable { let name: String; let age: Int }
        let userId = try await client.auth.session.user.id
        do {
            try await client.from("users")
                .update(Update(name: name, age: age))
                .eq("id", value: userId)
                .execute()
        } catch {
            throw AppError(error)
        }
    }

    func deleteAccount() async throws {
        try await callVoid("delete_my_account")
    }

    // MARK: Content

    func fetchTopics(limit: Int, offset: Int) async throws -> [Topic] {
        try await call("get_topics_with_progress", ["p_limit": limit, "p_offset": offset])
    }

    func fetchAvailableQuizzes(topicId: Int?, limit: Int, offset: Int) async throws -> [Quiz] {
        struct Params: Encodable {
            let p_topic_id: Int?
            let p_limit: Int
            let p_offset: Int
        }
        return try await call("get_available_quizzes", Params(p_topic_id: topicId, p_limit: limit, p_offset: offset))
    }

    // MARK: Sessions

    func fetchAttempts(status: QuizSession.Status, topicId: Int?, limit: Int, offset: Int) async throws -> [QuizAttempt] {
        struct Params: Encodable {
            let p_status: String
            let p_topic_id: Int?
            let p_limit: Int
            let p_offset: Int
        }
        return try await call(
            "get_my_sessions",
            Params(p_status: status.rawValue, p_topic_id: topicId, p_limit: limit, p_offset: offset)
        )
    }

    func startSession(quizId: Int) async throws -> QuizSession {
        try await call("start_quiz_session", ["p_quiz_id": quizId])
    }

    func saveProgress(sessionId: Int, answers: [AnswerSelection]) async throws -> QuizSession {
        try await call("save_quiz_progress", AnswersParams(p_session_id: sessionId, p_answers: answers))
    }

    func completeSession(sessionId: Int, answers: [AnswerSelection]) async throws -> QuizCompletion {
        try await call("complete_quiz_session", AnswersParams(p_session_id: sessionId, p_answers: answers))
    }

    func abandonSession(sessionId: Int) async throws {
        try await callVoid("abandon_quiz_session", ["p_session_id": sessionId])
    }

    // MARK: Plumbing

    private struct AnswersParams: Encodable {
        let p_session_id: Int
        let p_answers: [AnswerSelection]
    }

    private struct NoParams: Encodable {}

    private func call<Response: Decodable>(_ function: String) async throws -> Response {
        try await call(function, NoParams())
    }

    private func call<Response: Decodable>(_ function: String, _ params: some Encodable) async throws -> Response {
        let data: Data
        do {
            data = try await client.rpc(function, params: params).execute().data
        } catch {
            throw AppError(error)
        }
        do {
            return try JSONDecoder.api.decode(Response.self, from: data)
        } catch {
            #if DEBUG
            print("🔴 Decoding \(function) failed: \(error)\n\(String(decoding: data, as: UTF8.self))")
            #endif
            throw AppError.decoding
        }
    }

    private func callVoid(_ function: String, _ params: some Encodable = NoParams()) async throws {
        do {
            try await client.rpc(function, params: params).execute()
        } catch {
            throw AppError(error)
        }
    }
}
