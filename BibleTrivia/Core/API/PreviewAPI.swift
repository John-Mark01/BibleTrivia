//
//  PreviewAPI.swift
//  BibleTrivia
//

#if DEBUG
import Foundation

/// In-memory `BibleTriviaAPI` for SwiftUI previews and unit tests.
actor PreviewAPI: BibleTriviaAPI {
    private var profile = SampleData.profile
    private var available = SampleData.quizzes
    private var attempts: [QuizAttempt] = [SampleData.inProgressAttempt, SampleData.completedAttempt]
    private var nextSessionId = 100

    var failNextCall: AppError?

    func setFailNextCall(_ error: AppError?) { failNextCall = error }

    private func checkFailure() throws {
        if let error = failNextCall {
            failNextCall = nil
            throw error
        }
    }

    func checkIn(timeZone: String) async throws -> Streak {
        try checkFailure()
        return Streak(currentStreak: profile.currentStreak, longestStreak: profile.longestStreak)
    }

    func fetchProfile() async throws -> UserProfile {
        try checkFailure()
        return profile
    }

    func updateProfile(name: String, age: Int) async throws {
        try checkFailure()
        profile.name = name
        profile.age = age
    }

    func deleteAccount() async throws { try checkFailure() }

    func fetchTopics(limit: Int, offset: Int) async throws -> [Topic] {
        try checkFailure()
        return Array(SampleData.topics.dropFirst(offset).prefix(limit))
    }

    func fetchAvailableQuizzes(topicId: Int?, limit: Int, offset: Int) async throws -> [Quiz] {
        try checkFailure()
        let filtered = available.filter { topicId == nil || $0.topicId == topicId }
        return Array(filtered.dropFirst(offset).prefix(limit))
    }

    func fetchAttempts(status: QuizSession.Status, topicId: Int?, limit: Int, offset: Int) async throws -> [QuizAttempt] {
        try checkFailure()
        let filtered = attempts.filter {
            $0.session.status == status && (topicId == nil || $0.quiz.topicId == topicId)
        }
        return Array(filtered.dropFirst(offset).prefix(limit))
    }

    func startSession(quizId: Int) async throws -> QuizSession {
        try checkFailure()
        guard let quiz = available.first(where: { $0.id == quizId }) else {
            throw AppError.notFound("Quiz not found")
        }
        nextSessionId += 1
        let session = SampleData.session(id: nextSessionId, quiz: quiz, status: .inProgress, answers: [])
        available.removeAll { $0.id == quizId }
        attempts.append(QuizAttempt(session: session, quiz: quiz))
        return session
    }

    func saveProgress(sessionId: Int, answers: [AnswerSelection]) async throws -> QuizSession {
        try checkFailure()
        return try update(sessionId: sessionId, answers: answers, status: .inProgress).session
    }

    func completeSession(sessionId: Int, answers: [AnswerSelection]) async throws -> QuizCompletion {
        try checkFailure()
        let attempt = try update(sessionId: sessionId, answers: answers, status: .completed)
        profile.totalPoints += attempt.session.pointsEarned
        return QuizCompletion(
            session: attempt.session,
            totalPoints: profile.totalPoints,
            level: profile.level,
            leveledUp: false
        )
    }

    func abandonSession(sessionId: Int) async throws {
        try checkFailure()
        attempts.removeAll { $0.session.id == sessionId }
    }

    private func update(sessionId: Int, answers: [AnswerSelection], status: QuizSession.Status) throws -> QuizAttempt {
        guard let index = attempts.firstIndex(where: { $0.session.id == sessionId }) else {
            throw AppError.notFound("Quiz session not found")
        }
        let quiz = attempts[index].quiz
        let graded = SampleData.grade(answers, in: quiz)
        let session = SampleData.session(id: sessionId, quiz: quiz, status: status, answers: graded)
        attempts[index] = QuizAttempt(session: session, quiz: quiz)
        return attempts[index]
    }
}

enum SampleData {
    static let profile = UserProfile(
        id: UUID(), name: "Jacob Smith", email: "jacob@example.com", age: 30,
        level: .churchVolunteer, paymentPlan: .free, totalPoints: 180, joinedAt: .now,
        currentLevelMinPoints: 100, nextLevelMinPoints: 300,
        currentStreak: 4, longestStreak: 9, completedQuizzes: 1, inProgressQuizzes: 1
    )

    static let topics: [Topic] = [
        Topic(id: 1, name: "Genesis", quizCount: 4, completedQuizCount: 1, totalPoints: 220, earnedPoints: 40),
        Topic(id: 2, name: "The Life of Jesus", quizCount: 3, completedQuizCount: 0, totalPoints: 170, earnedPoints: 0),
        Topic(id: 3, name: "Acts & Paul", quizCount: 2, completedQuizCount: 2, totalPoints: 160, earnedPoints: 150),
    ]

    static func quiz(id: Int, topicId: Int = 1, name: String, difficulty: Difficulty = .newBorn) -> Quiz {
        Quiz(
            id: id, topicId: topicId, name: name, difficulty: difficulty, totalPoints: 60, timeToComplete: 3,
            questions: (1...3).map { n in
                let questionId = id * 10 + n
                return Question(
                    id: questionId,
                    text: "Sample question \(n) for \(name)",
                    explanation: "Because the Bible says so.",
                    answers: (1...4).map { a in
                        Answer(id: questionId * 10 + a, text: "Answer \(Question.letter(forAnswerAt: a - 1))", isCorrect: a == 1)
                    }
                )
            }
        )
    }

    static let quizzes: [Quiz] = [
        quiz(id: 1, name: "In the Beginning"),
        quiz(id: 2, name: "Abraham's Journey", difficulty: .sundaySchool),
        quiz(id: 3, topicId: 2, name: "Birth of Jesus"),
        quiz(id: 4, topicId: 2, name: "Miracles", difficulty: .youthPastor),
    ]

    static func session(id: Int, quiz: Quiz, status: QuizSession.Status, answers: [SavedAnswer]) -> QuizSession {
        let correct = answers.filter(\.isCorrect).count
        let percentage = quiz.numberOfQuestions > 0 ? Double(correct) * 100 / Double(quiz.numberOfQuestions) : 0
        return QuizSession(
            id: id, quizId: quiz.id, status: status, startedAt: .now.addingTimeInterval(-300),
            completedAt: status == .completed ? .now : nil, attemptNumber: 1, answers: answers,
            totalQuestions: quiz.numberOfQuestions, correctAnswers: correct,
            percentage: status == .completed ? percentage : nil,
            passed: status == .completed ? percentage >= 70 : nil,
            pointsEarned: status == .completed ? quiz.totalPoints * correct / max(quiz.numberOfQuestions, 1) : 0,
            timeSpentSeconds: status == .completed ? 300 : nil
        )
    }

    static func grade(_ selections: [AnswerSelection], in quiz: Quiz) -> [SavedAnswer] {
        selections.compactMap { selection in
            guard let question = quiz.questions.first(where: { $0.id == selection.questionId }),
                  let answer = question.answer(withId: selection.answerId) else { return nil }
            return SavedAnswer(questionId: question.id, answerId: answer.id, isCorrect: answer.isCorrect)
        }
    }

    static let inProgressAttempt: QuizAttempt = {
        let sample = Self.quiz(id: 7, name: "Kings of Israel", difficulty: .deacon)
        let first = sample.questions[0]
        return QuizAttempt(
            session: session(id: 7, quiz: sample, status: .inProgress,
                             answers: [SavedAnswer(questionId: first.id, answerId: first.answers[0].id, isCorrect: true)]),
            quiz: sample
        )
    }()

    static let completedAttempt: QuizAttempt = {
        let sample = Self.quiz(id: 8, name: "The Exodus")
        let answers = sample.questions.map { SavedAnswer(questionId: $0.id, answerId: $0.answers[0].id, isCorrect: true) }
        return QuizAttempt(session: session(id: 8, quiz: sample, status: .completed, answers: answers), quiz: sample)
    }()
}
#endif
