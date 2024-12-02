//
//  UserModel.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 2.12.24.
//

import Foundation

@Observable class UserModel {
    
    var name: String = ""
    var age: Int = 0
    var avatarString: String = "" //TODO: Create a enum with assotiated values (AvatarName / StringForImage)
    var userLevel: UserLevel = .newBorn
    var completedQuizzes: [Quiz] = []
    var totalPoints: Int = 0
    var streek: Int = 0
    var userPlan: UserPlan = .free
    
    
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
}


enum UserLevel: Int {
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

enum UserPlan: Int {
    case free
    case standard
    case premium
}
