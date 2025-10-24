//
//  TopicStore.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 22.10.25.
//

import Foundation
import SwiftUI

@MainActor
@Observable final class TopicStore: RouterAccessible, AuthenticatedStore {
    
// MARK: - Dependencies
    private let topicRepository: TopicRepositoryProtocol
    private(set) var alertManager: AlertManager
    private(set) var userId: UUID?
    
// MARK: - State Properties
    var allTopics: [Topic] = []
    private(set) var chosenTopic: Topic?
    var quizzesForSelectedTopic: [Quiz] = []
    var completedQuizzesForSelectedTopic: [CompletedQuiz] = []
    
// MARK: - Initialization
    
    init(supabase: Supabase) {
        self.topicRepository = TopicRepository(supabase: supabase)
        self.alertManager = .shared
    }
    
    // For testing with mock repository
    init(repository: TopicRepositoryProtocol, userId: UUID) {
        self.topicRepository = repository
        self.userId = userId
        self.alertManager = AlertManager.shared
    }
//MARK: - Computed Properties
        
    /// Safe access to current quiz
    var currentTopic: Topic {
        guard let topic = self.chosenTopic else {
            alertManager.showAlert(
                type: .error,
                message: "Unexpected Error, no topic is selected!",
                buttonText: "Go Back", action: { self.router.popBackStack() }
            )
            return Topic(id: 0, name: "N/A")
        }
        
        return topic
    }
    
// MARK: - Authentication
    /// Call this after user authenticates to set up the store
    func setUserId(_ id: UUID) {
        self.userId = id
    }
    
// MARK: - Topic Selection
    
    /// Select a topic and prepare to load its quizzes
    func selectTopic(_ topic: Topic) {
        log(with: "📌 User selected topic: \(topic.name)")
        self.chosenTopic = topic
    }
    
    /// Clear selected topic
    func unselectTopic() {
        log(with: "🔄 Clearing selected topic")
        self.chosenTopic = nil
        self.quizzesForSelectedTopic.removeAll()
    }
    
// MARK: - Topic Loading
    
    /// Load topics with user progress
    func loadTopicsWithUserProgress(limit: Int? = nil) async {
        guard let userId = requireAuthentication() else { return }
        
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        do {
            let topics = try await topicRepository.getTopicsWithUserProgress(userId: userId, limit: limit, offset: 0)
            
            await MainActor.run {
                withAnimation {
                    self.allTopics = topics
                }
            }
            
            log(with: "✅ Loaded \(topics.count) topics with progress")
            
        } catch {
            await MainActor.run {
                self.unexpectedError()
            }
            log(with: "❌ Unexpected error loading topics: \(error.localizedDescription)")
        }
    }
    
    func getTopicsForPagination(limit: Int?, offset: Int) async {
        guard let userId = requireAuthentication() else { return }
        
        do {
            let topics = try await topicRepository.getTopicsWithUserProgress(userId: userId, limit: limit, offset: offset)
            
            await MainActor.run {
                withAnimation {
                    self.allTopics.append(contentsOf: topics)
                }
            }
            
            log(with: "✅ Paginated \(topics.count) more topics with offset: \(offset), total: \(allTopics.count)")
            
        } catch {
            await MainActor.run {
                self.unexpectedError()
            }
            log(with: "❌ Unexpected error paginating topics: \(error.localizedDescription)")
        }
        
    }
    
    /// Refresh topics (reload with updated progress)
    func refreshTopics(amount: Int?) async {
        await loadTopicsWithUserProgress(limit: amount)
    }
    
    
// MARK: - Quiz Loading for Topic
    
    /// Load quizzes for a specific topic ID
    func loadNeverPlayedQuizzesForTopic(limit: Int? = nil, offset: Int = 0) async {
        guard let userId = requireAuthentication() else { return }
        guard let topicId = self.chosenTopic?.id else { return }
        
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        do {
            let quizzes = try await topicRepository.getNeverPlayedQuizzesForTopic(
                userId: userId,
                topicId: topicId,
                limit: limit,
                offset: offset
            )
            
            await MainActor.run {
                withAnimation {
                    self.quizzesForSelectedTopic = quizzes
                }
            }
            
            log(with: "✅ Loaded \(quizzes.count) quizzes for topic \(topicId)")
            
        } catch {
            await MainActor.run {
                self.unexpectedError()
            }
            log(with: "❌ Unexpected error loading quizzes: \(error.localizedDescription)")
        }
    }
    /// Load quizzes for a specific topic ID
    func loadCompletedQuizzesForTopic(limit: Int? = nil, offset: Int = 0) async {
        guard let userId = requireAuthentication() else { return }
        guard let topicId = self.chosenTopic?.id else { return }
        
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        do {
            let quizzes = try await topicRepository.getUserCompletedQuizzezForTopic(
                userId: userId,
                topicId: topicId,
                limit: limit,
                offset: offset
            )
            
            await MainActor.run {
                withAnimation {
                    self.completedQuizzesForSelectedTopic = quizzes
                }
            }
            
            log(with: "✅ Loaded \(quizzes.count) completed quizzes for topic \(topicId)")
            
        } catch {
            await MainActor.run {
                self.unexpectedError()
            }
            log(with: "❌ Unexpected error loading completed quizzes: \(error.localizedDescription)")
        }
    }
    
// MARK: - Helpers
    private func unexpectedError() {
        alertManager.showAlert(
            type: .error,
            message: "Unexpected error occurred",
            buttonText: "Dismiss",
            action: {}
        )
    }
    
    private func log(with message: String) {
        print("🟣 TopicStore: \(message)\n")
    }
}

// MARK: - Topic Statistics Extension

//extension TopicStore {
//    
//    /// Get total number of quizzes across all topics
//    var totalQuizCount: Int {
//        return allTopics.reduce(0) { $0 + $1.numberOfQuizes }
//    }
//    
//    /// Get total number of completed quizzes across all topics
//    var totalCompletedQuizCount: Int {
//        return allTopics.reduce(0) { $0 + $1.completedQuizzesCount }
//    }
//    
//    /// Get overall completion percentage across all topics
//    var overallCompletionPercentage: Double {
//        let total = totalQuizCount
//        guard total > 0 else { return 0.0 }
//        let completed = totalCompletedQuizCount
//        return Double(completed) / Double(total)
//    }
//    
//    /// Get topics sorted by completion percentage (descending)
//    var topicsSortedByProgress: [Topic] {
//        return allTopics.sorted { $0.completionPercentage > $1.completionPercentage }
//    }
//    
//    /// Get incomplete topics (topics with at least one uncompleted quiz)
//    var incompleteTopics: [Topic] {
//        return allTopics.filter { $0.completionPercentage < 1.0 }
//    }
//    
//    /// Get fully completed topics
//    var completedTopics: [Topic] {
//        return allTopics.filter { $0.completionPercentage == 1.0 }
//    }
//}
