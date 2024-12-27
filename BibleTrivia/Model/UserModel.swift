//
//  UserModel.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 2.12.24.
//

import Foundation

@Observable class UserModel {
    
    static var shared = UserModel()
    
    var name: String = "John-Mark Iliev"
    var age: Int = 0
    var avatarString: String = "Avatars/jacob" //TODO: Create a enum with assotiated values (AvatarName / StringForImage)
    var userLevel: UserLevel = .newBorn
    var completedQuizzes: [Quiz] = []
    var totalPoints: Int = 300
    var streek: Int = 12
    var userPlan: UserPlan = .free
    
    var nextLevel: UserLevel {
        switch userLevel {
        case .newBorn: return .churchVolunteer
        case .churchVolunteer: return .youthPastor
        case .youthPastor: return .deacon
        case .deacon: return .seniorPastor
        case .seniorPastor: return .seniorPastor
        }
    }
    
    
    init(name: String, userLevel: UserLevel) {
        self.name = name
        self.userLevel = userLevel
    }
    
    init(name: String, age: Int, avatarString: String, userLevel: UserLevel, completedQuizzes: [Quiz], points: Int, streek: Int, userPlan: UserPlan) {
        self.name = name
        self.age = age
        self.avatarString = avatarString
        self.userLevel = userLevel
        self.completedQuizzes = completedQuizzes
        self.totalPoints = points
        self.streek = streek
    }
    init() {}
}


enum UserLevel: Int {
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

enum UserPlan: Int {
    case free
    case standard
    case premium
}
