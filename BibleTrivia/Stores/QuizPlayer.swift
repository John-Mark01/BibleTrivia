//
//  QuizPlayer.swift
//  BibleTrivia
//

import Foundation

/// State for one quiz being played. Created by `QuizStore` when a quiz is started
/// or resumed, and discarded when the player leaves the quiz screen.
///
/// Pure in-memory logic; no networking, so it's fully unit-testable.
@MainActor
@Observable
final class QuizPlayer {

    enum Phase: Equatable {
        /// Answering questions.
        case playing
        /// Quiz submitted; results are shown.
        case finished
        /// Stepping through answered questions after finishing.
        case reviewing
    }

    enum SubmitOutcome: Equatable {
        case noSelection
        case advanced
        case reachedEnd
    }

    let quiz: Quiz
    private(set) var session: QuizSession
    private(set) var phase: Phase = .playing
    private(set) var currentIndex: Int
    /// Locked-in answers: question id → answer id.
    private(set) var submittedAnswers: [Int: Int]
    /// Answer highlighted on the current question but not yet submitted.
    private(set) var pendingAnswerId: Int?
    /// Server result, set once the quiz is completed.
    private(set) var completion: QuizCompletion?

    init(quiz: Quiz, session: QuizSession) {
        self.quiz = quiz
        self.session = session
        self.submittedAnswers = Dictionary(
            session.answers.map { ($0.questionId, $0.answerId) },
            uniquingKeysWith: { _, last in last }
        )
        let firstUnanswered = quiz.questions.firstIndex { !session.answers.map(\.questionId).contains($0.id) }
        self.currentIndex = firstUnanswered ?? max(quiz.questions.count - 1, 0)
    }

    // MARK: Derived state

    var currentQuestion: Question? {
        quiz.questions.indices.contains(currentIndex) ? quiz.questions[currentIndex] : nil
    }

    var questionNumber: Int { currentIndex + 1 }
    var isFirstQuestion: Bool { currentIndex == 0 }
    var isLastQuestion: Bool { currentIndex >= quiz.questions.count - 1 }

    var answeredCount: Int { submittedAnswers.count }

    /// Fraction of questions answered, 0...1.
    var progress: Double {
        guard !quiz.questions.isEmpty else { return 0 }
        return Double(answeredCount) / Double(quiz.questions.count)
    }

    var selections: [AnswerSelection] {
        quiz.questions.compactMap { question in
            submittedAnswers[question.id].map { AnswerSelection(questionId: question.id, answerId: $0) }
        }
    }

    /// The answer shown as selected for `question`: pending on the current
    /// question while playing, otherwise the submitted one.
    func selectedAnswerId(for question: Question) -> Int? {
        if phase == .playing, question.id == currentQuestion?.id {
            return pendingAnswerId ?? submittedAnswers[question.id]
        }
        return submittedAnswers[question.id]
    }

    /// Local correctness, for display only. The server's grading is authoritative.
    func isAnsweredCorrectly(_ question: Question) -> Bool {
        guard let answerId = submittedAnswers[question.id] else { return false }
        return question.answer(withId: answerId)?.isCorrect == true
    }

    var passed: Bool {
        completion?.session.passed ?? false
    }

    // MARK: Playing

    /// Highlights an answer on the current question; tapping it again clears it.
    func toggleSelection(answerId: Int) {
        guard phase == .playing, let question = currentQuestion else { return }
        pendingAnswerId = selectedAnswerId(for: question) == answerId ? nil : answerId
    }

    /// Locks in the selected answer and moves on.
    func submitCurrentAnswer() -> SubmitOutcome {
        guard phase == .playing, let question = currentQuestion else { return .noSelection }
        guard let answerId = pendingAnswerId ?? submittedAnswers[question.id] else { return .noSelection }

        submittedAnswers[question.id] = answerId
        pendingAnswerId = nil

        if let next = quiz.questions.indices.first(where: { $0 > currentIndex && submittedAnswers[quiz.questions[$0].id] == nil })
            ?? quiz.questions.indices.first(where: { submittedAnswers[quiz.questions[$0].id] == nil }) {
            currentIndex = next
            return .advanced
        }
        return .reachedEnd
    }

    func markCompleted(_ completion: QuizCompletion) {
        self.completion = completion
        self.session = completion.session
        phase = .finished
    }

    func updateSession(_ session: QuizSession) {
        self.session = session
    }

    // MARK: Review

    func startReview() {
        guard phase != .playing else { return }
        phase = .reviewing
        currentIndex = 0
    }

    func showResults() {
        guard phase == .reviewing else { return }
        phase = .finished
    }

    /// Returns false when already at the first question.
    @discardableResult
    func goToPreviousQuestion() -> Bool {
        guard phase == .reviewing, currentIndex > 0 else { return false }
        currentIndex -= 1
        return true
    }

    /// Returns false when already at the last question.
    @discardableResult
    func goToNextQuestion() -> Bool {
        guard phase == .reviewing, !isLastQuestion else { return false }
        currentIndex += 1
        return true
    }
}
