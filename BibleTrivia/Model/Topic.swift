//
//  Topic.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 12.10.24.
//

import Foundation

struct Topic {
    let name: String
    let quizes: [Quiz]
    
    var numberOfQuizes: Int {
        return quizes.count
    }
    
    var totalPoints: Int {
        return quizes.reduce(0) { $0 + $1.totalPoints }
    }
    
    var completenesLevel: Double {
        let completedQuizes = quizes.filter({ $0.status == .completed })
        return Double(numberOfQuizes / completedQuizes.count)
    }
}
