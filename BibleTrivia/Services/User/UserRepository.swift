//
//  UserRepository.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 28.09.25.
//

import Foundation

protocol UserRepositoryProtocol {
    func getInitialUserData(for userID: UUID) async throws -> UserModel
    func getUserStartedQuizzez(_ quizzez: [Int]?) async throws -> [Quiz]
}

class UserRepository: UserRepositoryProtocol {
    
    private let supabase: Supabase
    
    init(supabase: Supabase) {
        self.supabase = supabase
    }
    
    func getInitialUserData(for userID: UUID) async throws -> UserModel {
        do {
            return try await supabase.getUser(withId: userID)
        } catch {
            throw UserRepositoryError.userFetchFailed(error.localizedDescription.localized)
        }
    }
    
    func getUserStartedQuizzez(_ quizzez: [Int]?) async throws -> [Quiz] {
        do {
            return try await supabase.getFullDataQuizzes(withIDs: quizzez)
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
