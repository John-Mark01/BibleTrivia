//
//  Topic.swift
//  BibleTrivia
//

import Foundation

/// A topic with the current user's progress (`get_topics_with_progress`).
struct Topic: Identifiable, Hashable, Sendable, Decodable {
    let id: Int
    let name: String
    let quizCount: Int
    let completedQuizCount: Int
    let totalPoints: Int
    let earnedPoints: Int

    /// Fraction of quizzes completed, 0...1.
    var progress: Double {
        guard quizCount > 0 else { return 0 }
        return min(1, Double(completedQuizCount) / Double(quizCount))
    }

    var status: Status {
        if completedQuizCount == 0 { return .new }
        return completedQuizCount >= quizCount ? .completed : .inProgress
    }

    enum Status {
        case new, inProgress, completed

        var title: String {
            switch self {
            case .new: "New"
            case .inProgress: "In Progress"
            case .completed: "Completed"
            }
        }
    }
}
