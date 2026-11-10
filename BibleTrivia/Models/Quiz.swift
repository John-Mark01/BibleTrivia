//
//  Quiz.swift
//  BibleTrivia
//

import Foundation

// Quiz content is immutable and decoded straight from the `quiz_json` shape
// returned by the backend (snake_case keys, converted by `JSONDecoder.api`).
// Per-play state (selections, current question) lives in `QuizPlayer`.

struct Quiz: Identifiable, Hashable, Sendable, Decodable {
    let id: Int
    let topicId: Int
    let name: String
    let difficulty: Difficulty
    let totalPoints: Int
    /// Estimated minutes to complete.
    let timeToComplete: Double
    let questions: [Question]

    var numberOfQuestions: Int { questions.count }
}

struct Question: Identifiable, Hashable, Sendable, Decodable {
    let id: Int
    let text: String
    let explanation: String?
    let answers: [Answer]

    var correctAnswer: Answer? { answers.first(where: \.isCorrect) }

    func answer(withId id: Int) -> Answer? {
        answers.first { $0.id == id }
    }

    static func letter(forAnswerAt index: Int) -> String {
        guard (0..<26).contains(index) else { return "" }
        return String(UnicodeScalar(UInt8(65 + index)))
    }
}

struct Answer: Identifiable, Hashable, Sendable, Decodable {
    let id: Int
    let text: String
    /// Used only for local feedback and review. Scores are always computed by the server.
    let isCorrect: Bool
}

enum Difficulty: Int, CaseIterable, Sendable, Decodable {
    case newBorn = 0
    case sundaySchool
    case youthPastor
    case deacon
    case seniorPastor

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(Int.self)
        self = Difficulty(rawValue: raw) ?? .newBorn
    }

    var title: String {
        switch self {
        case .newBorn: "New Born"
        case .sundaySchool: "Sunday Schooler"
        case .youthPastor: "Youth Pastor"
        case .deacon: "Deacon"
        case .seniorPastor: "Senior Pastor"
        }
    }
}
