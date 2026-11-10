//
//  QuizStore.swift
//  BibleTrivia
//

import Foundation

/// Quizzes available to play, and the lifecycle of the quiz being played
/// (start → save/exit → complete). Keeps `UserStore` and `TopicStore` in sync
/// with what happens during play so views don't have to.
@MainActor
@Observable
final class QuizStore {
    private let api: BibleTriviaAPI
    private let alerts: AlertManager
    private let loading: LoadingManager
    private let userStore: UserStore
    private let topicStore: TopicStore

    /// Quizzes the user has never started, across all topics.
    private(set) var available = PagedList<Quiz>(pageSize: 20)
    /// The quiz currently on screen, if any.
    private(set) var player: QuizPlayer?

    init(api: BibleTriviaAPI, alerts: AlertManager, loading: LoadingManager, userStore: UserStore, topicStore: TopicStore) {
        self.api = api
        self.alerts = alerts
        self.loading = loading
        self.userStore = userStore
        self.topicStore = topicStore
    }

    // MARK: Available quizzes

    func loadAvailable(reset: Bool) async {
        guard let page = available.begin(reset: reset) else { return }
        do {
            let items = try await api.fetchAvailableQuizzes(topicId: nil, limit: page.limit, offset: page.offset)
            available.finish(with: items, reset: reset)
        } catch {
            available.fail()
            alerts.show(error)
        }
    }

    func loadMoreAvailableIfNeeded(after quiz: Quiz) async {
        guard available.shouldLoadMore(after: quiz) else { return }
        await loadAvailable(reset: false)
    }

    // MARK: Play lifecycle

    /// Starts `quiz` on the server and prepares a player. Returns false on failure.
    func start(_ quiz: Quiz) async -> Bool {
        guard !quiz.questions.isEmpty else {
            alerts.showAlert(type: .error, message: "This quiz has no questions yet.")
            return false
        }
        do {
            let session = try await loading.perform { try await api.startSession(quizId: quiz.id) }
            player = QuizPlayer(quiz: quiz, session: session)
            available.remove { $0.id == quiz.id }
            topicStore.didStart(quizId: quiz.id)
            userStore.didSaveProgress(QuizAttempt(session: session, quiz: quiz))
            return true
        } catch {
            alerts.show(error)
            return false
        }
    }

    /// Prepares a player for an unfinished quiz. No network needed.
    func resume(_ attempt: QuizAttempt) {
        player = QuizPlayer(quiz: attempt.quiz, session: attempt.session)
    }

    /// Saves answers so far. Returns false if saving failed, so the user can
    /// stay in the quiz and retry. The caller dismisses the quiz screen, which
    /// releases the player via `close()`.
    func saveAndExit() async -> Bool {
        guard let player else { return true }
        do {
            let session = try await loading.perform {
                try await api.saveProgress(sessionId: player.session.id, answers: player.selections)
            }
            player.updateSession(session)
            userStore.didSaveProgress(QuizAttempt(session: session, quiz: player.quiz))
            return true
        } catch {
            alerts.show(error)
            return false
        }
    }

    /// Submits all answers for server-side grading and moves the player to results.
    func complete() async {
        guard let player, player.completion == nil else { return }
        do {
            let result = try await loading.perform {
                try await api.completeSession(sessionId: player.session.id, answers: player.selections)
            }
            player.markCompleted(result)
            let attempt = QuizAttempt(session: result.session, quiz: player.quiz)
            userStore.didComplete(attempt, result: result)
            Task { await topicStore.didComplete(attempt) }
        } catch {
            alerts.show(error, buttonText: "Try Again") { [weak self] in
                Task { await self?.complete() }
            }
        }
    }

    /// Releases the player. Called when the quiz screen disappears.
    func close() {
        player = nil
    }

    func reset() {
        available.clear()
        player = nil
    }
}
