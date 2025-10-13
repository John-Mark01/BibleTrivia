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
    
    func exitQuiz(_ quiz: Quiz, onExit: @escaping (_ sessionId: Int) -> Void) async throws {
        //Send notification to Supabase
        guard let sessionId = sessionId else { return }
        try await quizSessionService.saveQuizProgress(sessionId: sessionId, quiz: quiz)
        
        let answeredCount = quiz.questions.filter { $0.userAnswer != nil }.count
        print("✅ Progress saved - \(answeredCount)/\(quiz.questions.count) questions answered")
        onExit(sessionId)
    }
    
    func resumeQuiz(quiz: Quiz, sessionId: Int) async -> Quiz? {
        do {
            // Get saved answers
            let savedAnswers = try await quizSessionService.resumeQuizSession(sessionId: sessionId)
            
            // Restore the quiz state
            var restoredQuiz = quiz
            quizSessionService.restoreQuizState(quiz: &restoredQuiz, savedAnswers: savedAnswers)
            
            self.sessionId = sessionId
            return restoredQuiz
        } catch {
            print("Error resuming: \(error)")
            return nil
        }
    }
    
    func enterReviewMode(for quiz: Quiz) {
        quiz.isInReview = true
        quiz.currentQuestionIndex = 0 // Start review from first question
    }
    
    func completeQuiz(_ quiz: Quiz) async throws -> CompletedQuiz? {
        quiz.status = .completed //TODO: Transfer functionality to quizStore as last action
        quiz.isFinished = true //TODO: Transfer functionality to quizStore as last action
        
        //Send notification to supabase
        guard let sessionId = sessionId else { return nil}
        try await quizSessionService.completeQuiz(sessionId: sessionId, quiz: quiz)
        
        print("✅ Quiz completed - \(quiz.name)")
        return CompletedQuiz(quiz: quiz, sessionId: sessionId)
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
