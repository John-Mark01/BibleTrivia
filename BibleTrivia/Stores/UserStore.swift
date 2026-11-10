//
//  UserStore.swift
//  BibleTrivia
//

import Foundation

/// The signed-in user's profile, streak and quiz history.
@MainActor
@Observable
final class UserStore {
    private let api: BibleTriviaAPI
    private let alerts: AlertManager

    private(set) var profile: UserProfile?
    /// Quizzes started but not finished, most recent first.
    private(set) var inProgress: [QuizAttempt] = []
    private(set) var completed = PagedList<QuizAttempt>(pageSize: 20)

    init(api: BibleTriviaAPI, alerts: AlertManager) {
        self.api = api
        self.alerts = alerts
    }

    // MARK: Loading

    /// Called once after sign-in: records the daily check-in, then loads the
    /// profile and unfinished quizzes in parallel.
    func loadInitialData() async {
        do {
            _ = try await api.checkIn(timeZone: TimeZone.current.identifier)
        } catch {
            // A failed check-in shouldn't block the app; the profile load below reports real problems.
            log("⚠️ check-in failed: \(error)")
        }

        do {
            async let profile = api.fetchProfile()
            async let inProgress = api.fetchAttempts(status: .inProgress, topicId: nil, limit: 50, offset: 0)
            self.profile = try await profile
            self.inProgress = try await inProgress
        } catch {
            alerts.show(error)
        }
    }

    func refreshProfile() async {
        do {
            profile = try await api.fetchProfile()
        } catch {
            log("⚠️ profile refresh failed: \(error)")
        }
    }

    func loadCompleted(reset: Bool) async {
        guard let page = completed.begin(reset: reset) else { return }
        do {
            let items = try await api.fetchAttempts(status: .completed, topicId: nil, limit: page.limit, offset: page.offset)
            completed.finish(with: items, reset: reset)
        } catch {
            completed.fail()
            alerts.show(error)
        }
    }

    func loadMoreCompletedIfNeeded(after attempt: QuizAttempt) async {
        guard completed.shouldLoadMore(after: attempt) else { return }
        await loadCompleted(reset: false)
    }

    // MARK: Updates from quiz play

    func didSaveProgress(_ attempt: QuizAttempt) {
        inProgress.removeAll { $0.id == attempt.id }
        inProgress.insert(attempt, at: 0)
        profile?.inProgressQuizzes = inProgress.count
    }

    func didComplete(_ attempt: QuizAttempt, result: QuizCompletion) {
        inProgress.removeAll { $0.id == attempt.id }
        completed.prepend(attempt)
        profile?.totalPoints = result.totalPoints
        profile?.level = result.level
        profile?.inProgressQuizzes = inProgress.count
        profile?.completedQuizzes += 1
    }

    func reset() {
        profile = nil
        inProgress = []
        completed.clear()
    }

    private func log(_ message: String) {
        #if DEBUG
        print("🔵 UserStore: \(message)")
        #endif
    }
}
