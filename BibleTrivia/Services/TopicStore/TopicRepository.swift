//
//  TopicRepository.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 22.10.25.
//

import Foundation

/// Repository protocol for topic data operations
protocol TopicRepositoryProtocol {
    func getTopicsWithUserProgress(userId: UUID, limit: Int?, offset: Int) async throws -> [Topic]
    func getNeverPlayedQuizzesForTopic(userId: UUID, topicId: Int, limit: Int?, offset: Int) async throws -> [Quiz]
    func getUserCompletedQuizzezForTopic(userId: UUID, topicId: Int, limit: Int?, offset: Int) async throws -> [CompletedQuiz]
}

/// Concrete implementation of TopicRepository using Supabase
class TopicRepository: TopicRepositoryProtocol {
    
    private let supabase: Supabase
    
    init(supabase: Supabase) {
        self.supabase = supabase
    }
    
// MARK: - Topics
    
    /// Fetch all topics without user progress
    func getTopicsWithUserProgress(userId: UUID, limit: Int? = nil, offset: Int = 0) async throws -> [Topic] {
        let topics = try await supabase.getTopics(limit: limit, offset: offset)
        for topic in topics {
            async let allQuizzesForTopic = try await supabase.getQuizzesWithTopicID(topic.id, limit: limit, offset: offset)
            async let playedQuizzes = try await supabase.getPlayedQuizzezIds(for: userId)
            let result = (try await playedQuizzes, try await allQuizzesForTopic)
            
            topic.playedQuizzes = result.0
            topic.quizes = result.1
        }
        return topics
    }
    
// MARK: - Quizzes for Topic
    
    /// Fetch all quizzes that a user has NEVER played before based on a specific topic
    func getNeverPlayedQuizzesForTopic(userId: UUID, topicId: Int, limit: Int?, offset: Int) async throws -> [Quiz] {
        return try await supabase.getQuizzesForTopic(userId: userId, topicId: topicId, limit: limit, offset: offset)
    }
    
    /// Fetch all quizzes that a user has played & COMPLETED before, based on a specific topic
    func getUserCompletedQuizzezForTopic(userId: UUID, topicId: Int, limit: Int?, offset: Int) async throws -> [CompletedQuiz] {
        return try await supabase.getCompletedQuizzesForTopic(userId: userId, topicId: topicId, limit: limit, offset: offset)
    }
}
