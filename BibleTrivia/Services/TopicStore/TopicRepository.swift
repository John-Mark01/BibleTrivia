//
//  TopicRepository.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 22.10.25.
//

import Foundation

/// Repository protocol for topic data operations
protocol TopicRepositoryProtocol {
    func getTopics(limit: Int?) async throws -> [Topic]
    func getQuizzesForTopic(topicId: Int) async throws -> [Quiz]
}

/// Concrete implementation of TopicRepository using Supabase
class TopicRepository: TopicRepositoryProtocol {
    
    private let supabase: Supabase
    
    init(supabase: Supabase) {
        self.supabase = supabase
    }
    
// MARK: - Topics
    
    /// Fetch all topics without user progress
    func getTopics(limit: Int? = nil) async throws -> [Topic] {
        return try await supabase.getTopics(limit: limit)
    }
    
// MARK: - Quizzes for Topic
    
    /// Fetch all quizzes for a specific topic (without questions/answers)
    func getQuizzesForTopic(topicId: Int) async throws -> [Quiz] {
        return try await supabase.getQuizzesWithTopicID(topicId)
    }
}
