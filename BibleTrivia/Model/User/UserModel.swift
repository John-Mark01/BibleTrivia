//
//  UserModel.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 2.12.24.
//

import Foundation

struct UserModel: Decodable {
    
    var name: String
    var age: Int
    var avatarString: String //TODO: Create a enum with assotiated values (AvatarName / StringForImage)
    var userLevel: UserLevel
    var completedQuizzes: [Quiz]
    var totalPoints: Int
    var streek: Int
    var userPlan: UserPlan
    
    private enum CodingKeys: String, CodingKey {
        case name
        case age
        case userLevel = "user_level"
        case avatarString = "avatar_string"
        case completedQuizzes = "completed_quizzes"
        case totalPoints = "total_points"
        case streek
        case userPlan = "user_plan"
    }
    
    var nextLevel: UserLevel {
        switch userLevel {
        case .newBorn: return .churchVolunteer
        case .churchVolunteer: return .youthPastor
        case .youthPastor: return .deacon
        case .deacon: return .seniorPastor
        case .seniorPastor: return .seniorPastor
        }
    }

    
    init(name: String, age: Int, avatarString: String, userLevel: UserLevel, completedQuizzes: [Quiz], points: Int, streek: Int, userPlan: UserPlan) {
        self.name = name
        self.age = age
        self.avatarString = avatarString
        self.userLevel = userLevel
        self.completedQuizzes = completedQuizzes
        self.totalPoints = points
        self.streek = streek
        self.userPlan = userPlan
    }
    
}


enum UserLevel: Int, Codable {
    case newBorn         = 0
    case churchVolunteer = 500
    case youthPastor     = 1200
    case deacon          = 2000
    case seniorPastor    = 3500
    
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
