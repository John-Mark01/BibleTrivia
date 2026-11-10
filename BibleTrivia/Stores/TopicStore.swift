//
//  TopicStore.swift
//  BibleTrivia
//

import Foundation

/// Topics with progress, and the quizzes of the currently selected topic.
@MainActor
@Observable
final class TopicStore {
    private let api: BibleTriviaAPI
    private let alerts: AlertManager

    private(set) var topics = PagedList<Topic>(pageSize: 20)

    private(set) var selectedTopic: Topic?
    /// Quizzes in the selected topic the user hasn't played yet.
    private(set) var topicQuizzes = PagedList<Quiz>(pageSize: 20)
    /// Quizzes in the selected topic the user has completed.
    private(set) var topicCompleted = PagedList<QuizAttempt>(pageSize: 20)

    init(api: BibleTriviaAPI, alerts: AlertManager) {
        self.api = api
        self.alerts = alerts
    }

    // MARK: Topics

    func loadTopics(reset: Bool) async {
        guard let page = topics.begin(reset: reset) else { return }
        do {
            topics.finish(with: try await api.fetchTopics(limit: page.limit, offset: page.offset), reset: reset)
        } catch {
            topics.fail()
            alerts.show(error)
        }
    }

    func loadMoreTopicsIfNeeded(after topic: Topic) async {
        guard topics.shouldLoadMore(after: topic) else { return }
        await loadTopics(reset: false)
    }

    // MARK: Selected topic

    func select(_ topic: Topic) {
        guard selectedTopic?.id != topic.id else { return }
        selectedTopic = topic
        topicQuizzes.clear()
        topicCompleted.clear()
    }

    func clearSelection() {
        selectedTopic = nil
        topicQuizzes.clear()
        topicCompleted.clear()
    }

    /// Loads the first page of new and completed quizzes for the selected topic.
    func loadSelectedTopicContent() async {
        guard let topicId = selectedTopic?.id else { return }
        async let quizzes: Void = loadTopicQuizzes(topicId: topicId, reset: true)
        async let completed: Void = loadTopicCompleted(topicId: topicId, reset: true)
        _ = await (quizzes, completed)
    }

    func loadMoreTopicQuizzesIfNeeded(after quiz: Quiz) async {
        guard let topicId = selectedTopic?.id, topicQuizzes.shouldLoadMore(after: quiz) else { return }
        await loadTopicQuizzes(topicId: topicId, reset: false)
    }

    func loadMoreTopicCompletedIfNeeded(after attempt: QuizAttempt) async {
        guard let topicId = selectedTopic?.id, topicCompleted.shouldLoadMore(after: attempt) else { return }
        await loadTopicCompleted(topicId: topicId, reset: false)
    }

    private func loadTopicQuizzes(topicId: Int, reset: Bool) async {
        guard let page = topicQuizzes.begin(reset: reset) else { return }
        do {
            let items = try await api.fetchAvailableQuizzes(topicId: topicId, limit: page.limit, offset: page.offset)
            guard selectedTopic?.id == topicId else { return topicQuizzes.fail() }
            topicQuizzes.finish(with: items, reset: reset)
        } catch {
            topicQuizzes.fail()
            alerts.show(error)
        }
    }

    private func loadTopicCompleted(topicId: Int, reset: Bool) async {
        guard let page = topicCompleted.begin(reset: reset) else { return }
        do {
            let items = try await api.fetchAttempts(status: .completed, topicId: topicId, limit: page.limit, offset: page.offset)
            guard selectedTopic?.id == topicId else { return topicCompleted.fail() }
            topicCompleted.finish(with: items, reset: reset)
        } catch {
            topicCompleted.fail()
            alerts.show(error)
        }
    }

    // MARK: Updates from quiz play

    func didStart(quizId: Int) {
        topicQuizzes.remove { $0.id == quizId }
    }

    func didComplete(_ attempt: QuizAttempt) async {
        if selectedTopic?.id == attempt.quiz.topicId {
            topicCompleted.prepend(attempt)
        }
        // Progress counts changed; refresh the first page quietly.
        if let page = topics.begin(reset: true) {
            do {
                topics.finish(with: try await api.fetchTopics(limit: page.limit, offset: page.offset), reset: true)
            } catch {
                topics.fail()
            }
        }
    }

    func reset() {
        topics.clear()
        clearSelection()
    }
}
