//
//  QuizManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on [Date]
//

import Foundation
import Supabase

final class QuizManager {
    
    let quizSessionService: QuizSessionService
    private var sessionId: Int?
    
    init(quizSessionService: QuizSessionService) {
        self.quizSessionService = quizSessionService
    }
    
    // MARK: - Answer Management
    
    func selectAnswer(at answerIndex: Int, in quiz: Quiz) {
        guard answerIndex < quiz.currentQuestion.answers.count else { return }
        
        //Don't select answer if there is already a selected one
        guard self.hasSelectedAnswer(in: quiz) == false else { return }
        
        quiz.currentQuestion.answers[answerIndex].isSelected = true
        return
    }
    
    func unselectAnswer(at answerIndex: Int, in quiz: Quiz) {
        guard answerIndex < quiz.currentQuestion.answers.count else { return }
        quiz.currentQuestion.answers[answerIndex].isSelected = false
    }
    
    func hasSelectedAnswer(in quiz: Quiz) -> Bool {
        return quiz.currentQuestion.answers.contains { $0.isSelected }
    }
    
    func getSelectedAnswer(in quiz: Quiz) -> Answer? {
        return quiz.currentQuestion.answers.first { $0.isSelected }
    }
    
    // MARK: - Question Navigation
    
    func submitCurrentQuestion(in quiz: Quiz) -> QuizSubmissionResult {
        guard let selectedAnswer = getSelectedAnswer(in: quiz) else {
            return .failure(.noAnswerSelected)
        }
        
        // Set the user's answer
        //TODO: Save for supabase
        quiz.currentQuestion.userAnswer = selectedAnswer
        
        // Check if this was the last question
        if isLastQuestion(in: quiz) {
            return .success(.quizCompleted)
        } else {
            return .success(.moveToNext)
        }
    }
    
    func moveToNextQuestion(in quiz: Quiz) -> Bool {
        guard !isLastQuestion(in: quiz) else { return false }
        
        quiz.currentQuestionIndex += 1
        return true
    }
    
    func moveToPreviousQuestion(in quiz: Quiz) -> Bool {
        guard quiz.currentQuestionIndex > 0 else { return false }
        
        quiz.currentQuestionIndex -= 1
        return true
    }
    
    
    func moveToNextQuestionInReview(in quiz: Quiz) -> Bool {
        guard quiz.currentQuestionIndex + 1 < quiz.numberOfQuestions else { return false }
        
        quiz.currentQuestionIndex += 1
        return true
    }
    
    func isLastQuestion(in quiz: Quiz) -> Bool {
        return quiz.currentQuestionIndex >= quiz.numberOfQuestions - 1
    }
    
    func isFirstQuestion(in quiz: Quiz) -> Bool {
        return quiz.currentQuestionIndex == 0
    }
    
    // MARK: - Progress Calculation
    
    func calculateProgress(in quiz: Quiz) -> Double {
        let answeredQuestions = quiz.questions.filter { $0.userAnswer != nil }
        return Double(answeredQuestions.count) / Double(quiz.numberOfQuestions)
    }
    
    func calculateProgressString(in quiz: Quiz) -> String {
        let progress = calculateProgress(in: quiz)
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        percentageFormatter.maximumFractionDigits = 0
        return percentageFormatter.string(from: NSNumber(value: progress)) ?? "0%"
    }
    
    func calculateCurrentQuestionProgress(in quiz: Quiz) -> Double {
        guard quiz.isFinished == false else { return Double(quiz.numberOfQuestions) }
        return Double(quiz.currentQuestionIndex + 1) / Double(quiz.numberOfQuestions)
    }
    
// MARK: - Quiz Management
    
    func startQuiz(_ quiz: Quiz) async throws {
        quiz.status = .started
        quiz.currentQuestionIndex = 0
        quiz.isInReview = false
        quiz.isFinished = false
        
        //Send notification to Supabase
        sessionId = try await quizSessionService.startQuiz(quiz)
    }
    
    func exitQuiz(_ quiz: Quiz) async throws {
        //Send notification to Supabase
        guard let sessionId = sessionId else { return }
        try await quizSessionService.saveQuizProgress(sessionId: sessionId, quiz: quiz)
        
        let answeredCount = quiz.questions.filter { $0.userAnswer != nil }.count
        print("✅ Progress saved - \(answeredCount)/\(quiz.questions.count) questions answered")
    }
    
    func enterReviewMode(for quiz: Quiz) {
        quiz.isInReview = true
        quiz.currentQuestionIndex = 0 // Start review from first question
    }
    
    func completeQuiz(_ quiz: Quiz) async throws {
        quiz.status = .completed //TODO: Transfer functionality to quizStore as last action
        quiz.isFinished = true //TODO: Transfer functionality to quizStore as last action
        
        //Send notification to supabase
        guard let sessionId = sessionId else { return }
        try await quizSessionService.completeQuiz(sessionId: sessionId, quiz: quiz)
        
        let correctCount = quiz.questions.filter { $0.userAnswer?.isCorrect == true }.count
        print("✅ Quiz completed - Score: \(correctCount)/\(quiz.questions.count)")
    }
    
// MARK: - Answer Evaluation
    func isCurrentAnswerCorrect(in quiz: Quiz) -> Bool {
        guard let userAnswer = quiz.currentQuestion.userAnswer else { return false }
        return userAnswer.isCorrect
    }
    
    func calculateScore(in quiz: Quiz) -> Int {
        let correctAnswers = quiz.questions.filter { question in
            question.userAnswer?.isCorrect == true
        }
        return correctAnswers.count
    }
   
    func hasUserPassedQuiz(_ quiz: Quiz) -> Bool {
        return quiz.questions.allSatisfy { question in
            question.userAnswer?.isCorrect == true
        }
    }
    
    func calculateCompletionPercentage(in quiz: Quiz) -> Double {
        let totalQuestions = quiz.numberOfQuestions
        guard totalQuestions > 0 else { return 0.0 }
        
        let correctAnswers = calculateScore(in: quiz)
        return Double(correctAnswers) / Double(totalQuestions)
    }
}

// MARK: - Supporting Types

enum QuizSubmissionResult {
    case success(QuizSubmissionAction)
    case failure(QuizSubmissionError)
}

enum QuizSubmissionAction {
    case moveToNext
    case quizCompleted
}

enum QuizSubmissionError {
    case noAnswerSelected
    case quizAlreadyCompleted
} 


//MARK: - Supabase

struct QuizSessionResponse: Codable {
    let id: Int
    let userId: String
    let quizId: Int
    let startedAt: String
    let status: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case quizId = "quiz_id"
        case startedAt = "started_at"
        case status
    }
}

struct SavedAnswer: Codable {
    let questionId: Int
    let answerId: Int
    let isCorrect: Bool
    let answeredAt: String
    
    private enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case answerId = "answer_id"
        case isCorrect = "is_correct"
        case answeredAt = "answered_at"
    }
}

// MARK: - Quiz Session Service


class QuizSessionService {
    private let supabaseClient: SupabaseClient
    private let userId: UUID
    
    init(supabaseClient: SupabaseClient, userId: UUID) {
        self.supabaseClient = supabaseClient
        self.userId = userId
    }
    
    // MARK: - 1. Start Quiz (First Network Call)
    
    /// Call this when user taps "Start Quiz"
    /// Returns the session ID to track this quiz attempt
    func startQuiz(_ quiz: Quiz) async throws -> Int {
        struct InsertSession: Encodable {
            let user_id: String
            let quiz_id: Int
            let total_questions: Int
            let status: String = "in_progress"
        }
        
        let newSession = InsertSession(
            user_id: userId.uuidString,
            quiz_id: quiz.id,
            total_questions: quiz.questions.count
        )
        
        let response: [QuizSessionResponse] = try await supabaseClient
            .from("user_quiz_sessions")
            .insert(newSession)
            .select()
            .execute()
            .value
        
        guard let session = response.first else {
            throw NSError(domain: "QuizError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to create quiz session"])
        }
        
        return session.id
    }
    
    // MARK: - 2. Save Quiz Progress (Second Network Call - when exiting)
    
    /// Call this when user exits without completing
    /// Saves all answered questions so they can resume later
    func saveQuizProgress(sessionId: Int, quiz: Quiz) async throws {
        let answers = extractAnswers(from: quiz)
        
        guard !answers.isEmpty else {
            // No answers to save
            return
        }
        
        let answersJSON = try JSONEncoder().encode(answers)
        let answersJSONB = String(data: answersJSON, encoding: .utf8) ?? "[]"
        
        let _ = try await supabaseClient
            .rpc("save_quiz_progress", params: [
                "session_id_param": String(sessionId),
                "answers_param": answersJSONB,
                "is_completed": "false"
            ])
            .execute()
            .value
    }
    
    // MARK: - 3. Complete Quiz (Third Network Call - when finishing)
    
    /// Call this when user completes the quiz
    /// Marks session as completed and calculates final score
    func completeQuiz(sessionId: Int, quiz: Quiz) async throws {
        let answers = extractAnswers(from: quiz)
        let answersJSON = try JSONEncoder().encode(answers)
        let answersJSONB = String(data: answersJSON, encoding: .utf8) ?? "[]"
        
        let _ = try await supabaseClient
            .rpc("save_quiz_progress", params: [
                "session_id_param": String(sessionId),
                "answers_param": answersJSONB,
                "is_completed": "true"
            ])
            .execute()
            .value
    }
    
    // MARK: - Helper Methods
    
    /// Extract answers from Quiz object
    private func extractAnswers(from quiz: Quiz) -> [SavedAnswer] {
        let dateFormatter = ISO8601DateFormatter()
        let now = dateFormatter.string(from: Date())
        
        return quiz.questions.compactMap { question in
            guard let userAnswer = question.userAnswer else {
                return nil // Question not answered
            }
            
            return SavedAnswer(
                questionId: question.id,
                answerId: userAnswer.id,
                isCorrect: userAnswer.isCorrect,
                answeredAt: now
            )
        }
    }
    
    // MARK: - Resume Quiz
    
    /// Get in-progress quizzes for the user
    func getInProgressQuizzes() async throws -> [QuizSessionResponse] {
        let sessions: [QuizSessionResponse] = try await supabaseClient
            .from("user_quiz_sessions")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("status", value: "in_progress")
            .order("last_saved_at", ascending: false)
            .execute()
            .value
        
        return sessions
    }
    
    /// Resume a specific quiz session
    /// Returns the saved answers to restore quiz state
    func resumeQuizSession(sessionId: Int) async throws -> [SavedAnswer] {
        struct SessionWithAnswers: Codable {
            let answers: [SavedAnswer]
        }
        
        let session: SessionWithAnswers = try await supabaseClient
            .from("user_quiz_sessions")
            .select("answers")
            .eq("id", value: sessionId)
            .single()
            .execute()
            .value
        
        return session.answers
    }
    
    /// Restore quiz state from saved answers
    func restoreQuizState(quiz: inout Quiz, savedAnswers: [SavedAnswer]) {
        // Create a map of question_id -> saved answer
        let answerMap = Dictionary(uniqueKeysWithValues: savedAnswers.map { ($0.questionId, $0) })
        
        // Restore user answers to questions
        for i in 0..<quiz.questions.count {
            let questionId = quiz.questions[i].id
            
            if let savedAnswer = answerMap[questionId] {
                // Find the answer in the question's answers array
                if let answerIndex = quiz.questions[i].answers.firstIndex(where: { $0.id == savedAnswer.answerId }) {
                    quiz.questions[i].answers[answerIndex].isSelected = true
                    quiz.questions[i].userAnswer = quiz.questions[i].answers[answerIndex]
                }
            }
        }
        
        // Update current question index to first unanswered question
        if let firstUnanswered = quiz.questions.firstIndex(where: { $0.userAnswer == nil }) {
            quiz.currentQuestionIndex = firstUnanswered
        } else {
            // All questions answered
            quiz.currentQuestionIndex = quiz.questions.count - 1
        }
    }
}
