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
    
    
    
    // EMAIL && Password
    func signUp(email: String, password: String, firstName: String = "", lastName: String = "", age: String) async throws {
        
        let userName = "\(firstName) \(lastName)".capitalized
        let userAge = Int(age) ?? 0
        
        try await supabase.auth.signUp(
            email: email,
            password: password,
            data: [
                "first_name": .string(firstName),
                "last_name": .string(lastName),
                "user_name": .string(userName),
                "age": .integer(userAge),
            ]
        )
    }
    
    func signIn(email: String, password: String, callBack: @escaping (Bool) -> Void) async throws {
        LoadingManager.shared.show()
        
        do {
            try await supabase.auth.signIn(email: email, password: password)
            print("Succsessfull sign in - \(email)")
            callBack(true)
            LoadingManager.shared.hide()
        }
        catch {
            LoadingManager.shared.hide()
            print("Coudnt sign in")
        }
    }
    
}
