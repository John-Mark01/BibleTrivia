//
//  UserModel.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 2.12.24.
//

import Foundation

@Observable
class UserModel {
    var name: String = ""
    var age: Int = 0
    var email: String? = ""
    var userLevel: UserLevel = .newBorn
    var userPlan: UserPlan = .free
    var completedQuizzes: [Int]? = []
    var startedQuizzes: [Int]? = []
    var totalPoints: Int = 0
    var streak: Int = 0
    var joinedAt: Date = .now
    
    var nextLevel: UserLevel {
        switch userLevel {
        case .newBorn: return .churchVolunteer
        case .churchVolunteer: return .youthPastor
        case .youthPastor: return .deacon
        case .deacon: return .seniorPastor
        case .seniorPastor: return .seniorPastor
        }
    }
    init() {}
    init(name: String, age: Int, email: String?, userLevel: UserLevel, userPlan: UserPlan, completedQuizzes: [Int]?, startedQuizzes: [Int]?, totalPoints: Int, streak: Int, joinedAt: Date) {
        self.name = name
        self.age = age
        self.email = email
        self.userLevel = userLevel
        self.userPlan = userPlan
        self.completedQuizzes = completedQuizzes
        self.startedQuizzes = startedQuizzes
        self.totalPoints = totalPoints
        self.streak = streak
        self.joinedAt = joinedAt
    }
}


enum UserLevel: Int, Codable {
    case newBorn         = 0
    case churchVolunteer = 1
    case youthPastor     = 2
    case deacon          = 3
    case seniorPastor    = 4
    
    var stringValue : String {
        switch self {
        case .newBorn:
            return "New Born"
        case .churchVolunteer:
            return "Church Volunteer"
        case .youthPastor:
            return "Youth Pastor"
        case .deacon:
            return "Deacon"
        case .seniorPastor:
            return "Senior Pastor"
        }
    }
}

enum UserPlan: Int, Codable {
    case free
    case standard
    case premium
}

//MARK: - Server communcaiton

struct UserModelPayload: Decodable {
    var name: String
    var age: Int
    var email: String?
    var level: UserLevel
    var paymentPlan: UserPlan
    var completedQuizzes: [Int]? //codingKey
    var startedQuizzes: [Int]? //codingKey
    var totalPoints: Int //codingKey
    var streak: Int
    var joinedAt: Date //codingKey
    
    private enum CodingKeys: String, CodingKey {
        case name
        case age
        case email
        case level
        case paymentPlan = "payment_plan"
        case completedQuizzes = "completed_quizzez_ids"
        case startedQuizzes = "started_quizzez_ids"
        case totalPoints = "total_points"
        case streak
        case joinedAt = "joined_at"
    }
    
    func toUser() -> UserModel {
        return UserModel(
            name: self.name,
            age: self.age,
            email: self.email,
            userLevel: self.level,
            userPlan: self.paymentPlan,
            completedQuizzes: self.completedQuizzes,
            startedQuizzes: self.startedQuizzes,
            totalPoints: self.totalPoints,
            streak: self.streak,
            joinedAt: self.joinedAt
        )
    }
}
