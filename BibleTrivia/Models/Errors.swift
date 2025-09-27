//
//  Errors.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 4.01.25.
//

import Foundation

@Observable
class Errors {
    
    enum BTError: Error {
        // Fetching - C
        case networkError(LocalizedStringResource)
        case invalidResponse(LocalizedStringResource)
        case parseError(LocalizedStringResource)
        
        // Inserting - R
        
        // Updating - U
        
        // Deleting - D
        
        // Authentication
        case signUpError(LocalizedStringResource)
        case logInError(LocalizedStringResource)
        case forgotPasswordError(LocalizedStringResource)
        
        //General
        case unknownError(LocalizedStringResource)
    }
}
