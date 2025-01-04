//
//  Errors.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 4.01.25.
//

import Foundation


@Observable
class Errors {
    
    enum SupabaseError: Error {
        // Fetching - C
        case networkError(String)
        case invalidResponse(String)
        case parseError(String)
        
        // Inserting - R
        
        // Updating - U
        
        // Deleting - D
        
        // Authentication
        case signUpError(String)
        case logInError(String)
        case forgotPasswordError(String)
        
        //General
        case unknownError(String)
        
    }
}
