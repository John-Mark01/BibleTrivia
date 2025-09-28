//
//  SupabaseClient.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 22.12.24.
//

import Foundation
import Supabase

@Observable class Supabase {
    
    let supabaseClient = SupabaseClient(supabaseURL: Secrets.supabaseURL, supabaseKey: Secrets.supabaseAPIKey)
    
    enum Table {
        static let users     = "users"
        static let topics    = "topics"
        static let quizez    = "quizzez"
        static let questions = "questions"
        static let answers   = "answers"
    }
    
    enum ParseType: String {
        case topic, quiz, question, answer, user
    }
}

//MARK: - Fetching Data

extension Supabase {
    
    //Topics
    func getTopics(limit: Int? = nil, offset: Int = 0) async throws -> [Topic] {
        let query = supabaseClient
            .from(Table.topics)
            .select()
        
        // Add pagination if limit is provided
        if let limit = limit {
            let response = try await query
                .range(from: offset, to: offset + limit - 1)
                .execute()
            let topics = try parseVoidResponse(response, for: .topic) as? [Topic]
            return topics ?? []
        } else {
            // Get all if no limit specified
            let response = try await query.execute()
            let topics = try parseVoidResponse(response, for: .topic) as? [Topic]
            return topics ?? []
        }
    }
    
    func parseTopics(_ data: Data) throws -> [Topic] {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let topicsPayload = try decoder.decode([TopicPayload].self, from: data)
            var topics: [Topic] = []
            topicsPayload.forEach {
                 topics.append(convertPayloadToTopic($0))
            }
            return topics
        } catch {
            print("Error decoding quizzes: \(error)")
            throw Errors.BTError.parseError("Error getting topics. Please try again later.")
        }
    }
    
    func convertPayloadToTopic(_ payload: TopicPayload) -> Topic {
        return Topic(id: payload.id, name: payload.name)
    }
    
    //Quizzes
    func getQuizzez(limit: Int? = nil, offset: Int = 0, ids: [Int]? = nil) async throws -> [Quiz] {
        let baseQuery = supabaseClient
            .from(Table.quizez)
            .select()
        
        let response: PostgrestResponse<Void>
        
        // IDs specified
        if let ids = ids, !ids.isEmpty {
            // Get specific quizzes by IDs
            if let limit = limit {
                // IDs with pagination
                response = try await baseQuery
                    .in("id", values: ids)
                    .range(from: offset, to: offset + limit - 1)
                    .execute()
            } else {
                // IDs without pagination
                response = try await baseQuery
                    .in("id", values: ids)
                    .execute()
            }
        } else {
            // No IDs specified
            if let limit = limit {
                // Pagination only
                response = try await baseQuery
                    .range(from: offset, to: offset + limit - 1)
                    .execute()
            } else {
                // Get all quizzes
                response = try await baseQuery.execute()
            }
        }
        
        let quizzez = try parseVoidResponse(response, for: .quiz) as? [Quiz]
        return quizzez ?? []
    }
    
    func getQuizWithTopicID(_ id: Int) async throws -> Quiz? {
        do {
            let response = try await supabaseClient
                .from(Table.quizez)
                .select()
                .eq("topic_id", value: id)
                .execute()
            let quizzez = try parseVoidResponse(response, for: .quiz) as? [Quiz]
            
            return quizzez?.first
        } catch {
            print("Error decoding quizzes: \(error)")
            throw Errors.BTError.parseError("Error getting quiz. Please try again later.")
        }
    }
    
    func getQuizWithID(_ id: Int) async throws -> Quiz? {
        do {
            let response = try await supabaseClient
                .from(Table.quizez)
                .select()
                .eq("id", value: id)
                .execute()
            let quizzez = try parseVoidResponse(response, for: .quiz) as? [Quiz]
            
            return quizzez?.first
        }
    }
    
    func parseQuizzes(_ data: Data) throws -> [Quiz] {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let quizPayload = try decoder.decode([QuizPayload].self, from: data)
            var quizzes: [Quiz] = []
             quizPayload.forEach {
                quizzes.append(convertPayloadToQuiz($0))
            }
            return quizzes
        } catch {
            print("Error decoding quizzes: \(error)")
            throw Errors.BTError.parseError("Error getting quiz. Please try again later.")
        }
    }
    
    func convertPayloadToQuiz(_ payload: QuizPayload) -> Quiz {
        
        var quizTime: TimeInterval = 0
        var quizPoints: Int = 0
        var quizTopicId: Int = 0
        
        if let timeToComplete = payload.timeToComplete, let totalPoints = payload.totalPoints, let topicId = payload.topicId {
            quizTime = timeToComplete
            quizPoints = Int(totalPoints)
            quizTopicId = topicId
        }
        return Quiz(id: payload.id, name: payload.name, topicId: quizTopicId, time: quizTime, status: payload.status, difficulty: payload.difficulty, totalPoints: quizPoints)
    }
    
    //Questions
    func getQuestions(for quizID: Int) async throws -> [Question] {
        do {
            let response =
            try await supabaseClient
                .from(Table.questions)
                .select()
                .eq("quiz_id", value: quizID) // filters all the questions for the array
                .execute()
            
            let questions = try parseVoidResponse(response, for: .question) as? [Question]
            return questions ?? []
        } catch {
            throw Errors.BTError.parseError("Error getting question for quiz. Please contact us.")
        }
    }
    
    func parseQuestions(_ data: Data) throws -> [Question] {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let questionPayload = try decoder.decode([QuestionPayload].self, from: data)
            var questions: [Question] = []
            questionPayload.forEach {
                questions.append(convertPayloadToQuestion($0))
            }
            return questions
        } catch {
            print("Error decoding quizzes: \(error)")
            throw Errors.BTError.parseError("Error getting questions for quiz. Please try again later.")
        }
    }
    
    func convertPayloadToQuestion(_ payload: QuestionPayload) -> Question {
        
        var explaination: String = ""
        
        if let safeExplaination = payload.explaination {
            explaination = safeExplaination
        }
        return Question(id: payload.id, text: payload.text, explaination: explaination, quizId: payload.quizId)
    }
    
    
    //Answers
    func getAnswers(for questionIds: [Int]) async throws -> [Answer] {
       let response =
            try await supabaseClient
            .from(Table.answers)
            .select()
            .in("question_id", values: questionIds) // Filter by array of question IDs
            .execute()
        
        let answers = try parseVoidResponse(response, for: .answer) as? [Answer]
        return answers ?? []
    }
    
    func parseAnswers(_ data: Data) throws -> [Answer] {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let answerPayload = try decoder.decode([AnswerPayload].self, from: data)
            var answers: [Answer] = []
            answerPayload.forEach {
                answers.append(convertPayloadToAnswer($0))
            }
            return answers
        } catch let error {
            print("Error decoding answers: \(error)")
            throw Errors.BTError.parseError("Coudn't get answers for Quiz. Please Try again later.")
        }
    }
    
    func convertPayloadToAnswer(_ payload: AnswerPayload) -> Answer {
        return Answer(id: payload.id, text: payload.text, questionId: payload.questionId, isCorrect: payload.isCorrect)
    }
    
    
    
    //Users
    func getUser(withId id: UUID) async throws -> UserModel {
        let response =
        try await supabaseClient
            .from(Table.users)
            .select()
            .eq("id", value: id)
            .execute()
        
        let user = try parseVoidResponse(response, for: .user) as? UserModel
        return user ?? .init()
    }
    
    private func parseUsers(_ data: Data) throws -> UserModel? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let userPayload = try decoder.decode([UserModelPayload].self, from: data)
            return userPayload.first?.toUser()
        } catch let error {
            print("Error decoding User: \(error)")
            throw Errors.BTError.parseError("Coudn't get User data. Please Try again later.")
        }
    }
    
    
//MARK: - Helpers
    func parseVoidResponse(_ response: PostgrestResponse<Void>, for parseType: ParseType) throws -> Any {
        print("Get \(parseType.rawValue.capitalized)s with status code: \(response.response.statusCode)")
        
        switch response.status {
        case 200:
            switch parseType {
            case .topic:
                return try parseTopics(response.data)
            case .quiz:
                return try parseQuizzes(response.data)
            case .question:
                return try parseQuestions(response.data)
            case .answer:
                return try parseAnswers(response.data)
            case .user:
                return try parseUsers(response.data)
            }
        default:
            throw Errors.BTError.networkError("Network Error. Please try again later.")
        }
    }
    
}

extension Supabase {
    enum StatusCode: Int, CaseIterable {
        case succsess = 200
    }
}
