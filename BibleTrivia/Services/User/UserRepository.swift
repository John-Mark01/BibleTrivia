//
//  UserRepository.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 28.09.25.
//

import Foundation

protocol UserRepositoryProtocol {
    func getInitialUserData(for userID: UUID) async throws -> UserModel
    func getUserStartedQuizzez() async throws -> [StartedQuiz]
    func getUserCompletedQuizzez() async throws -> [CompletedQuiz]
}

class UserRepository: UserRepositoryProtocol {
    
    private let supabase: Supabase
    private let quizSessionManager: QuizSessionService

    
    init(supabase: Supabase) {
        let userID: UUID = UUID(uuidString: UserDefaults.standard.string(forKey: "userID") ?? "") ?? .init()
        self.quizSessionManager = QuizSessionService(supabaseClient: supabase.supabaseClient, userId: userID)
        
        self.supabase = supabase
    }
    
    func getInitialUserData(for userID: UUID) async throws -> UserModel {
        return try await supabase.getUser(withId: userID)
    }
    
    func getUserStartedQuizzez() async throws -> [StartedQuiz] {
        let sessions = try await quizSessionManager.getInProgressQuizzes()
        
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
    
    func getUserCompletedQuizzez() async throws -> [CompletedQuiz] {
        let sessions = try await quizSessionManager.getCompletedQuizzes()
        
        // For each session, fetch the full Quiz from your server
        var quizzez: [CompletedQuiz] = []
        for session in sessions {
//            let quiz = try await supabase.getFullDataQuizzes(withIDs: [session.quizId]).first
            let quiz = try await supabase.getQuizezWithIDs([session.quizId]).first
            guard let quiz else { continue }
            
            let model = CompletedQuiz(quiz: quiz, session: session)
            quizzez.append(model)
        }
        
        return quizzez
    }
}
