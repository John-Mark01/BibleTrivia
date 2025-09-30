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
        do {
            return try await supabase.getUser(withId: userID)
        } catch {
            throw UserRepositoryError.userFetchFailed(error.localizedDescription.localized)
        }
    }
    
    func getUserStartedQuizzez() async throws -> [StartedQuiz] {
        do {
            let sessions = try await quizSessionManager.getInProgressQuizzes()
            
            // Step 2: For each session, fetch the full Quiz from your server
            var quizzez: [StartedQuiz] = []
            for session in sessions {
                let quiz = try await supabase.getFullDataQuizzes(withIDs: [session.quizId]).first
                guard let quiz else { continue }
                
                let model = StartedQuiz(sessionId: session.id, quiz: quiz)
                quizzez.append(model)
            }
            
            return quizzez
        } catch {
            print("error: \(error.localizedDescription)")
            throw UserRepositoryError.userFetchFailed(error.localizedDescription.localized)
        }
    }

    
    
// MARK: - Repository Errors
    enum UserRepositoryError: Error, LocalizedError {
        case userFetchFailed(LocalizedStringResource)
        case startedQuizzezFetchFailed(LocalizedStringResource)
        
        var errorDescription: LocalizedStringResource? {
            switch self {
            case let .userFetchFailed(message):
                return "Failed to get user: \(message)"
            case let .startedQuizzezFetchFailed(message):
                return "Failed to get user started quizzez: \(message)"
            }
        }
        
        /// Converts repository errors to the app's BTError format
        func toBTError() -> Errors.BTError {
            switch self {
            case let .userFetchFailed(message),
                 let .startedQuizzezFetchFailed(message):
                return .parseError(message)
            }
        }
    }
}
