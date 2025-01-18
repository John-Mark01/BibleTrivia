//
//  AuthManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 5.01.25.
//

import SwiftUI
import Supabase

@Observable class AuthManager {
    
    let supabase = SupabaseClient(supabaseURL: Secrets.supabaseURL, supabaseKey: Secrets.supabaseAPIKey)
    
    
    enum AuthAction: String, CaseIterable {
        case signUp = "Sign Up"
        case signIn = "Sign In"
    }
    
    
    
    
    

    
}
