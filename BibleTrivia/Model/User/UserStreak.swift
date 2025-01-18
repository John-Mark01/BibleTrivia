//
//  UserStreak.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 5.01.25.
//

import Foundation

struct UserStreak: Codable {
    let id: UUID
    let userId: UUID
    var currentStreak: Int
    var longestStreak: Int
    var lastVisit: Date
    var lastStreakUpdate: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case lastVisit = "last_visit"
        case lastStreakUpdate = "last_streak_update"
    }
    
//    init(id: UUID, userId: UUID, currentStreak: Int, longestStreak: Int, lastVisit: Date, lastStreakUpdate: Date) {
//        self.id = id
//        self.userId = userId
//        self.currentStreak = currentStreak
//        self.longestStreak = longestStreak
//        self.lastVisit = lastVisit
//        self.lastStreakUpdate = lastStreakUpdate
//    }
}
