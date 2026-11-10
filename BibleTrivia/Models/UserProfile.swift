//
//  UserProfile.swift
//  BibleTrivia
//

import Foundation

/// The signed-in user's profile and stats (`get_my_profile`).
struct UserProfile: Hashable, Sendable, Decodable {
    let id: UUID
    var name: String
    let email: String?
    var age: Int
    var level: UserLevel
    let paymentPlan: UserPlan
    var totalPoints: Int
    let joinedAt: Date
    var currentLevelMinPoints: Int
    /// `nil` when the user is at the highest level.
    var nextLevelMinPoints: Int?
    var currentStreak: Int
    var longestStreak: Int
    var completedQuizzes: Int
    var inProgressQuizzes: Int

    var firstName: String {
        name.split(separator: " ").first.map(String.init) ?? name
    }

    /// Progress from the current level's threshold to the next, 0...1.
    var levelProgress: Double {
        guard let next = nextLevelMinPoints, next > currentLevelMinPoints else { return 1 }
        let progress = Double(totalPoints - currentLevelMinPoints) / Double(next - currentLevelMinPoints)
        return min(max(progress, 0), 1)
    }
}

enum UserLevel: Int, CaseIterable, Sendable, Decodable {
    case newBorn = 0
    case churchVolunteer
    case youthPastor
    case deacon
    case seniorPastor

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(Int.self)
        self = UserLevel(rawValue: raw) ?? .newBorn
    }

    var title: String {
        switch self {
        case .newBorn: "New Born"
        case .churchVolunteer: "Church Volunteer"
        case .youthPastor: "Youth Pastor"
        case .deacon: "Deacon"
        case .seniorPastor: "Senior Pastor"
        }
    }

    var next: UserLevel? { UserLevel(rawValue: rawValue + 1) }
}

enum UserPlan: Int, Sendable, Decodable {
    case free = 0
    case standard
    case premium

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(Int.self)
        self = UserPlan(rawValue: raw) ?? .free
    }
}
