//
//  DifficultyLevel.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 12.10.24.
//

import Foundation

enum DifficultyLevel: Int, CaseIterable, Codable {
    case newBorn = 0
    case sundaySchool
    case youthPastor
    case deacon
    case seniorPastor
    
    func getAsString() -> String {
        switch self {
        case .newBorn:
            return "New Born"
        case .sundaySchool:
            return "sundaySchool"
        case .youthPastor:
            return "Youth Pastor"
        case .deacon:
            return "Deacon"
        case .seniorPastor:
            return "Senior Pastor"
        }
    }
}
