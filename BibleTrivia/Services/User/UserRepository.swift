//
//  UserRepository.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 28.09.25.
//

import Foundation

protocol UserRepositoryProtocol {
    func getInitialUserData(for userID: UUID) async throws -> UserModel
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

    
    
// MARK: - Repository Errors
    enum UserRepositoryError: Error, LocalizedError {
        case userFetchFailed(LocalizedStringResource)
        
        var errorDescription: LocalizedStringResource? {
            switch self {
            case let .userFetchFailed(message):
                return "Failed to get user: \(message)"
            }
        }
        
        /// Converts repository errors to the app's BTError format
        func toBTError() -> Errors.BTError {
            switch self {
            case let .userFetchFailed(message):
                return .parseError(message)
            }
        }
    }
}
