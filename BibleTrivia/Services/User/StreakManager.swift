//
//  StreakManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 5.01.25.
//

import Foundation
import Supabase


class StreakManager {
    
    private let supabase: SupabaseClient = SupabaseClient(supabaseURL: Secrets.supabaseURL, supabaseKey: Secrets.supabaseAPIKey)
    
    /// Updates user's streak based on their last visit
    func checkIn(userId: UUID) async throws -> UserStreak {
        let now = Date()
        
        // Try to fetch existing streak
        let query = supabase
            .from("user_streaks")
            .select()
            .eq("user_id", value: userId)
        
        let response = try await query.execute()
        print(response.string() ?? "")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Get existing streak or create new one
        var streak: UserStreak
        if let existingStreak = try? decoder.decode([UserStreak].self, from: response.data).first {
            streak = existingStreak
        } else {
            // Create new streak record
            streak = UserStreak(
                id: UUID(),
                userId: userId,
                currentStreak: 0,
                longestStreak: 0,
                lastVisit: now,
                lastStreakUpdate: now
            )
        }
        
        // Calculate hours since last visit
        let hoursSinceLastVisit = now.timeIntervalSince(streak.lastVisit) / 3600
        
        // Update streak based on time passed
        if hoursSinceLastVisit > 24 {
            // Reset streak if more than 24 hours passed
            streak.currentStreak = 0
        } else if !Calendar.current.isDate(now, inSameDayAs: streak.lastVisit) {
            // Increment streak if it's a new day but within 24 hours
            streak.currentStreak += 1
            streak.longestStreak = max(streak.currentStreak, streak.longestStreak)
        }
        
        // Update timestamps
        streak.lastVisit = now
        streak.lastStreakUpdate = now
        
        // Save to Supabase
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//        let encodedStreak = try encoder.encode(streak)
//        let streakDict = try JSONSerialization.jsonObject(with: encodedStreak) as! UserStreak
        
        if streak.id == UUID() {
            // Insert new record
            try await supabase
                .from("user_streaks")
                .insert(streak)
                .execute()
        } else {
            // Update existing record
            try await supabase
                .from("user_streaks")
                .update(streak)
                .eq("id", value: streak.id)
                .execute()
        }
        
        return streak
    }
    
    /// Reset all expired streaks (should be called daily)
    func resetExpiredStreaks() async throws {
        let twentyFourHoursAgo = Date().addingTimeInterval(-24 * 3600)
        
        // Update all streaks where last_visit is more than 24 hours ago
        try await supabase
            .from("user_streaks")
            .update(["current_streak": 0])
            .lt("last_visit", value: twentyFourHoursAgo)
            .execute()
    }
}
