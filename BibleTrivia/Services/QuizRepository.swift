//
//  QuizRepository.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on [Date]
//

import Foundation

/// Repository protocol for quiz data operations
/// Follows Dependency Inversion Principle - depend on abstractions, not concretions
protocol QuizRepositoryProtocol {
    func getTopics(limit: Int?) async throws -> [Topic]
    func getQuizzes(limit: Int?, offset: Int) async throws -> [Quiz]
    func getQuestions(for quizId: Int) async throws -> [Question]
    func getAnswers(for questionIds: [Int]) async throws -> [Answer]
    func getQuizWithTopicID(_ topicId: Int) async throws -> Quiz?
}

/// Concrete implementation of QuizRepository using Supabase
class QuizRepository: QuizRepositoryProtocol {
    
    private let supabase: Supabase
    
    init(supabase: Supabase) {
        self.supabase = supabase
    }
    
    // MARK: - Topics
    
    func getTopics(limit: Int? = nil) async throws -> [Topic] {
        do {
            return try await supabase.getTopics(limit: limit)
        } catch {
            throw QuizRepositoryError.topicsFetchFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Quizzes
    
    func getQuizzes(limit: Int? = nil, offset: Int = 0) async throws -> [Quiz] {
        do {
            let quizzes = try await supabase.getQuizzez(limit: limit, offset: offset)
            
            // Fill each quiz with its questions and answers
            for quiz in quizzes {
                let questions = try await getQuestionsWithAnswers(for: quiz.id)
                quiz.questions = questions
            }
            
            return quizzes
        } catch let error as QuizRepositoryError {
            throw error
        } catch {
            throw QuizRepositoryError.quizzesFetchFailed(error.localizedDescription)
        }
    }
    
    func getQuizWithTopicID(_ topicId: Int) async throws -> Quiz? {
        do {
            guard let quiz = try await supabase.getQuizWithTopicID(topicId) else {
                return nil
            }
            
            let questions = try await getQuestionsWithAnswers(for: quiz.id)
            quiz.questions = questions
            
            return quiz
        } catch {
            throw QuizRepositoryError.quizFetchFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Questions
    
    func getQuestions(for quizId: Int) async throws -> [Question] {
        do {
            return try await supabase.getQuestions(for: quizId)
        } catch {
            throw QuizRepositoryError.questionsFetchFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Answers
    
    func getAnswers(for questionIds: [Int]) async throws -> [Answer] {
        do {
            return try await supabase.getAnswers(for: questionIds)
        } catch {
            throw QuizRepositoryError.answersFetchFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getQuestionsWithAnswers(for quizId: Int) async throws -> [Question] {
        do {
            let questions = try await getQuestions(for: quizId)
            let questionIds = questions.map { $0.id }
            let answers = try await getAnswers(for: questionIds)
            
            // Group answers by question ID
            let answersDict = Dictionary(grouping: answers) { $0.questionId }
            
            // Add answers to their respective questions
            let questionsWithAnswers = questions.map { question in
                var updatedQuestion = question
                updatedQuestion.answers = answersDict[question.id] ?? []
                return updatedQuestion
            }
            
            return questionsWithAnswers
        } catch let error as QuizRepositoryError {
            throw error
        } catch {
            throw QuizRepositoryError.questionsFetchFailed("Failed to fetch questions with answers: \(error.localizedDescription)")
        }
    }
}

// MARK: - Repository Errors

enum QuizRepositoryError: Error, LocalizedError {
    case topicsFetchFailed(String)
    case quizzesFetchFailed(String)
    case quizFetchFailed(String)
    case questionsFetchFailed(String)
    case answersFetchFailed(String)
    case networkError(String)
    case parseError(String)
    
    var errorDescription: String? {
        switch self {
        case .topicsFetchFailed(let message):
            return "Failed to fetch topics: \(message)"
        case .quizzesFetchFailed(let message):
            return "Failed to fetch quizzes: \(message)"
        case .quizFetchFailed(let message):
            return "Failed to fetch quiz: \(message)"
        case .questionsFetchFailed(let message):
            return "Failed to fetch questions: \(message)"
        case .answersFetchFailed(let message):
            return "Failed to fetch answers: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .parseError(let message):
            return "Parse error: \(message)"
        }
    }
    
    /// Converts repository errors to the app's BTError format
    func toBTError() -> Errors.BTError {
        switch self {
        case .topicsFetchFailed(let message), 
             .quizzesFetchFailed(let message), 
             .quizFetchFailed(let message),
             .questionsFetchFailed(let message), 
             .answersFetchFailed(let message):
            return .parseError(message)
        case .networkError(let message):
            return .networkError(message)
        case .parseError(let message):
            return .parseError(message)
        }
    }
} 