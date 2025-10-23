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
    
// MARK: - Topic Loading
    
    /// Load topics with user progress
    func loadTopics(limit: Int? = nil) async {
        guard let userId = requireAuthentication() else { return }
        
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        do {
            let topics = try await topicRepository.getTopics(limit: limit)
            
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
    
    /// Refresh topics (reload with updated progress)
    func refreshTopics(amount: Int?) async {
        await loadTopics(limit: amount)
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
    
// MARK: - Quiz Loading for Topic
    
    /// Load all quizzes for the currently selected topic
    func loadQuizzesForSelectedTopic() async {
        guard let topic = chosenTopic else {
            log(with: "⚠️ No topic selected to load quizzes")
            return
        }
        
        await loadQuizzes(forTopicId: topic.id)
    }
    
    /// Load quizzes for a specific topic ID
    func loadQuizzes(forTopicId topicId: Int) async {
        guard let userId = requireAuthentication() else { return }
        
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        do {
            let quizzes = try await topicRepository.getQuizzesForTopic(topicId: topicId)
            
            
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
    
    // MARK: - Progress Queries //TODO:
    
    // MARK: - Private Helpers
    
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
