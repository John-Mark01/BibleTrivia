//
//  Secrets.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 22.12.24.
//

import Foundation

enum Secrets {
    
    static var supabaseURL: URL {
        guard let urlString = ProcessInfo.processInfo.environment["SUPABASE_URL"],
              let url = URL(string: urlString) else {
            fatalError("SUPABASE_URL environment variable not set or invalid")
        }
        return url
    }
    
    static var supabaseAPIKey: String {
        guard let apiKey = ProcessInfo.processInfo.environment["SUPABASE_API_KEY"] else {
            fatalError("SUPABASE_API_KEY environment variable not set")
        }
        return apiKey
    }
} 