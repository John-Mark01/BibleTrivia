//
//  SupabaseClient.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 22.12.24.
//

import Foundation
import Supabase

@Observable class Supabase {
    
    
    let supabase = SupabaseClient(supabaseURL: Secrets.supabaseURL, supabaseKey: Secrets.supabaseAPIKey)
    
    enum Table {
        static let users = "users"
        static let topics = "topics"
        static let quizez = "quizzez"
        static let questions = "questions"
        static let answers = "answers"
    }
}

//MARK: Fetching Data

extension Supabase {
    
    func getTopics() async throws {
        try await supabase
            .from(Table.topics)
            .select()
            .order("name")
            .execute()
            .value
    }
}


//MARK: Authentication

extension Supabase {
    
    enum AuthAction: String, CaseIterable {
        case signUp = "Sign Up"
        case signIn = "Sign In"
    }
    
    
    // EMAIL && Password
    func signUp(email: String, password: String) async throws {
        
        try await supabase.auth.signUp(email: email, password: password)
    }
    
    func signIn(email: String, password: String, callBack: @escaping (Bool) -> Void) async throws {
        do {
            try await supabase.auth.signIn(email: email, password: password)
            print("Succsessfull sign in - \(email)")
            callBack(true)
        }
        catch {
            print("Coudnt sign in")
        }
    }
}
