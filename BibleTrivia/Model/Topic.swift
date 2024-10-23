//
//  Topic.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 12.10.24.
//

import Foundation

struct Topic {
    let id = UUID()
    var name: String
    var quizes: [Quiz]
    var status: TopicStatus
    
    var numberOfQuizes: Int {
        return quizes.count
    }
    
    var totalPoints: Int {
        return quizes.reduce(0) { $0 + $1.totalPoints }
    }
    
    var completenesLevel: Double {
        let completedQuizes: [Quiz] = quizes.filter({$0.status == .completed })
        guard completedQuizes.count != 0 else {return 0.0}
        
        
        return Double(numberOfQuizes / completedQuizes.count)
    }
    
    var progressString: String {
        let progress = completenesLevel
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        percentageFormatter.maximumFractionDigits = 0
        return percentageFormatter.string(from: NSNumber(value: progress)) ?? "0%"
    }
    

}

enum TopicStatus: Int, CaseIterable {
    
    case neverPlayed
    case new
    case highScore
    case mostPlayed
    
    var stringValue: String {
        switch self {
        case .neverPlayed:
            return "Never Played"
        case .new:
            return "New"
        case .highScore:
            return "High Scored"
        case .mostPlayed:
            return "Most Played"
        }
    }
}
