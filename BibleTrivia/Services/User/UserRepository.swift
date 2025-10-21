//
//  UserRepository.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 28.09.25.
//

import Foundation

protocol UserRepositoryProtocol {
    func getInitialUserData(for userId: UUID) async throws -> UserModel
    func getUserStartedQuizzez(for userId: UUID) async throws -> [StartedQuiz]
    func getUserCompletedQuizzez(for userId: UUID) async throws -> [CompletedQuiz]
    func getUserCompletedQuizzezCount(for userId: UUID) async throws -> Int
}

final class UserRepository: UserRepositoryProtocol {
    
    private let supabase: Supabase
    private let quizSessionManager: QuizSessionService

    init(supabase: Supabase) {
        self.supabase = supabase
        self.quizSessionManager = QuizSessionService(supabaseClient: supabase.supabaseClient)
    }
    
    func getInitialUserData(for userId: UUID) async throws -> UserModel {
        return try await supabase.getUser(withId: userId)
    }
    
    func getUserStartedQuizzez(for userId: UUID) async throws -> [StartedQuiz] {
        let sessions = try await quizSessionManager.getInProgressQuizzes(for: userId)
        
        // For each session, fetch the full Quiz from your server
        var quizzez: [StartedQuiz] = []
        for session in sessions {
            let quiz = try await supabase.getFullDataQuizzes(withIDs: [session.quizId]).first
            guard let quiz else { continue }
            
            let model = StartedQuiz(sessionId: session.id, quiz: quiz)
            quizzez.append(model)
        }
        
        return quizzez
    }
    
    func getUserCompletedQuizzez(for userId: UUID) async throws -> [CompletedQuiz] {
        let sessions = try await quizSessionManager.getCompletedQuizzes(for: userId)
        
        // For each session, fetch the full Quiz from your server
        var quizzez: [CompletedQuiz] = []
        for session in sessions {
            let quiz = try await supabase.getQuizezWithIDs([session.quizId]).first
            guard let quiz else { continue }
            
            let model = CompletedQuiz(quiz: quiz, sessionId: session.id, session: session)
            quizzez.append(model)
        }
        
        return quizzez
    }
    
    func getUserCompletedQuizzezCount(for userId: UUID) async throws -> Int {
        let sessions = try await quizSessionManager.getCompletedQuizzes(for: userId)
        return sessions.count
    }
}
