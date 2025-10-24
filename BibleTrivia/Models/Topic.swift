//
//  Topic.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 12.10.24.
//

import Foundation

@Observable class Topic {
    var id: Int = 0
    var name: String
    var quizes: [Quiz] = [.init(), .init(), .init(), .init()]
    var playedQuizzes: [Int] = [1]
    var status: TopicStatus {
        if playedQuizzes.isEmpty {
            return .new
        }
        return .new
    }
    
    var numberOfQuizes: Int {
        return quizes.count
    }
    
    var totalPoints: Int {
        return quizes.reduce(0) { $0 + $1.totalPoints }
    }
    
    private var completenesLevel: Double {
        return Double(playedQuizzes.count) / Double(numberOfQuizes)
    }
    
    var progressString: String {
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        percentageFormatter.maximumFractionDigits = 0
        return percentageFormatter.string(from: NSNumber(value: completenesLevel)) ?? "0%"
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

}

enum TopicStatus: Int, CaseIterable {
    case new
    case highScore
    case mostPlayed
    
    var stringValue: String {
        switch self {
        case .new:
            return "New"
        case .highScore:
            return "High Scored"
        case .mostPlayed:
            return "Most Played"
        }
    }
}

//MARK: Server request parsing
struct TopicPayload: Decodable {
    let id: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
