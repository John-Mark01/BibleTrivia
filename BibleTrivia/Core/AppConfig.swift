//
//  AppConfig.swift
//  BibleTrivia
//

import Foundation

/// Build-time configuration injected through `Config.xcconfig` → `Info.plist`.
/// Debug builds point at the dev Supabase project, Release builds at production.
enum AppConfig {
    static let supabaseURL: URL = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let url = URL(string: value), url.host() != nil else {
            fatalError("SUPABASE_URL is missing or invalid. Create Config.xcconfig from Config.example.xcconfig.")
        }
        return url
    }()

    static let supabaseKey: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_API_KEY") as? String,
              !value.isEmpty, !value.hasPrefix("$(") else {
            fatalError("SUPABASE_API_KEY is missing. Create Config.xcconfig from Config.example.xcconfig.")
        }
        return value
    }()

    /// Deep-link callback for auth emails. Must be listed in Supabase Auth → URL Configuration.
    /// Scheme matching is case-insensitive; compare with `isAuthDeepLink(_:)`.
    static let authCallbackURL = URL(string: "bibleTrivia://auth/callback")!
    static let passwordResetURL = URL(string: "bibleTrivia://auth/reset-password")!

    static func isAuthDeepLink(_ url: URL) -> Bool {
        url.scheme?.lowercased() == "bibletrivia" && url.host()?.lowercased() == "auth"
    }
}
