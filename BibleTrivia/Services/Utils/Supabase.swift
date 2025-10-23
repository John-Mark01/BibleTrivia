//
//  SupabaseClient.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 22.12.24.
//

import Foundation
import Supabase

enum Table {
    static let users     = "users"
    static let topics    = "topics"
    static let quizez    = "quizzez"
    static let questions = "questions"
    static let answers   = "answers"
    static let sessions  = "user_quiz_sessions"
}

enum ParseType: String {
    case topic, quiz, question, answer, user
}

@Observable class Supabase {
    
    let supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
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
    func getAllAvailableQuizzez(userId: UUID, limit: Int? = nil, offset: Int = 0) async throws -> [Quiz] {
        let completedQuizzez: [Int] = try await getUnavailableQuizzezIds(for: userId)
        
        var query = supabaseClient
            .from(Table.quizez)
            .select()
        
        if !completedQuizzez.isEmpty {
            let idsList = completedQuizzez.map(String.init).joined(separator: ",")
            let inValue = "(\(idsList))" // -> "(1,2,3)"
            query = query.not("id", operator: .in, value: inValue) // exclude all completed quizzez
        }
        
        // Add pagination if limit is provided
        if let limit = limit {
            let response = try await query
                .range(from: offset, to: offset + limit - 1)
                .execute()
            let quizzez = try parseVoidResponse(response, for: .quiz) as? [Quiz]
            return quizzez ?? []
        } else {
            // Get all if no limit specified
            let response = try await query.execute()
            let quizzez = try parseVoidResponse(response, for: .quiz) as? [Quiz]
            return quizzez ?? []
        }
    }
    
    func getQuizzesWithTopicID(_ id: Int) async throws -> [Quiz] {
        do {
            let response = try await supabaseClient
                .from(Table.quizez)
                .select()
                .eq("topic_id", value: id)
                .execute()
            let quizzez = try parseVoidResponse(response, for: .quiz) as? [Quiz]
            
            return quizzez ?? []
        } catch {
            print("Error decoding quizzes: \(error)")
            throw Errors.BTError.parseError("Error getting quiz. Please try again later.")
        }
    }
    
    //TODO: Used only in UserRepository
    func getQuizezWithIDs(_ ids: [Int]?) async throws -> [Quiz] {
        guard let ids, !ids.isEmpty else { return [] }
        
        let response = try await supabaseClient
            .from(Table.quizez)
            .select()
            .in("id", values: ids)
            .execute()
        let quizzez = try parseVoidResponse(response, for: .quiz) as? [Quiz]
        return quizzez ?? []
    }
    
    private func getUnavailableQuizzezIds(for userId: UUID) async throws -> [Int] {
        
        // Get all completed quiz IDs for this user
        struct CompletedQuiz: Codable {
            let quiz_id: Int
        }
        
        let completedQuizzes: [CompletedQuiz] = try await supabaseClient
            .from(Table.sessions)
            .select("quiz_id")
            .eq("user_id", value: userId)
            .or(#"status.eq.in_progress, status.eq.completed"#) // get both in_progress and completed
            .execute()
            .value
        
        let completedIds = completedQuizzes.map { $0.quiz_id }
        
        return completedIds
    }
    
    func parseQuizzes(_ data: Data) throws -> [Quiz] {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let quizPayload = try decoder.decode([QuizPayload].self, from: data)
            var quizzes: [Quiz] = []
             quizPayload.forEach {
                 quizzes.append($0.toQuiz())
            }
            return quizzes
        } catch {
            print("Error decoding quizzes: \(error)")
            throw Errors.BTError.parseError("Error getting quiz. Please try again later.")
        }
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
    
    func getQuestionsWithAnswers(for quizId: Int) async throws -> [Question] {
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
    
    //Quiz + Questions + Answers
    //TODO: Used Only in UserRepository
    func getFullDataQuizzes(withIDs ids: [Int]?) async throws -> [Quiz] {
        let quizzes = try await getQuizezWithIDs(ids)
        for quiz in quizzes {
            let questions = try await getQuestionsWithAnswers(for: quiz.id)
            quiz.questions = questions
        }
        
        return quizzes
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
