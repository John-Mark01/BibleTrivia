//
//  QuizStore.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 16.10.24.
//

import Foundation
import SwiftUI

@MainActor
@Observable class QuizStore {
    
    // MARK: - Dependencies
    private let quizRepository: QuizRepositoryProtocol
    private let quizManager: QuizManager
    private let alertManager: AlertManager
    
    // MARK: - State Properties
    var allTopics: [Topic] = []
    var allQuizez: [Quiz] = []
    var startedQuizez: [Quiz] = []
    var chosenQuiz: Quiz?
    var chosenTopic: Topic?
    
    // MARK: - Initialization
    
    init(supabase: Supabase) {
        self.quizRepository = QuizRepository(supabase: supabase)
        self.quizManager = QuizManager()
        self.alertManager = AlertManager.shared
    }
    
    // For testing with mock repository
    init(repository: QuizRepositoryProtocol, manager: QuizManager) {
        self.quizRepository = repository
        self.quizManager = manager
        self.alertManager = AlertManager.shared
    }
    
    // MARK: - Computed Properties
    
    /// Safe access to current quiz
    var currentQuiz: Quiz {
        let answers = [Answer(id: 1, text: "Error", questionId: 0, isCorrect: true)]
        let questions = [Question(text: "Error", explanation: "Error", answers: answers)]
        let quiz = Quiz(name: "Error", questions: questions, time: 0, status: .new, difficulty: .deacon, totalPoints: 10)
        guard let quiz = chosenQuiz else {
//            return Quiz(id: 0, name: "Error", topicId: 0, time: 0, status: 0, difficulty: 0, totalPoints: 0)
            return quiz
        }
        return quiz
    }
    
    // MARK: - Quiz Selection & Management
    
    func chooseQuiz(quiz: Quiz) {
        self.chosenQuiz = quiz
    }
    
    func cancelChoosingQuiz(onCancel: @escaping () -> Void) {
        self.chosenQuiz = nil
        onCancel()
    }
    
    func startQuiz(onStart: @escaping (Bool) -> Void) {
        guard let unwrappedQuiz = chosenQuiz else {
            showAlert(alertTitle: "Error", 
                     message: "Unexpected Error, no quiz selected!", 
                     buttonTitle: "Go Back")
            onStart(false)
            return
        }
        
        quizManager.startQuiz(unwrappedQuiz)
        startedQuizez.append(unwrappedQuiz)
        onStart(true)
    }
    
    func quitQuiz(onQuit: @escaping () -> Void) {
        self.chosenQuiz = nil
        onQuit()
    }
    
    // MARK: - Answer Management
    
    func selectAnswer(index: Int) {
        guard let quiz = chosenQuiz else { return }
        
        if quizManager.selectAnswer(at: index, in: quiz) {
            selectAnswerHaptic()
        }
    }
    
    func unselectAnswer(index: Int) {
        guard let quiz = chosenQuiz else { return }
        
        quizManager.unselectAnswer(at: index, in: quiz)
        selectAnswerHaptic()
    }
    
    // MARK: - Question Navigation
    
    func answerQuestion() -> QuizQuestionResult {
        guard let quiz = chosenQuiz else {
            showAlert(alertTitle: "Error",
                     message: "No quiz selected",
                     buttonTitle: "Okay")
            return .error
        }
        
        let result = quizManager.submitCurrentQuestion(in: quiz)
        
        switch result {
        case .success(let action):
            switch action {
            case .moveToNext:
                return .moveToNext
            case .quizCompleted:
                return .quizCompleted
            }
        case .failure(let submissionError):
            switch submissionError {
            case .noAnswerSelected:
                showAlert(alertTitle: "Warning",
                         message: "No answer selected!\nPlease select an answer",
                         buttonTitle: "Okay")
                return .error
            case .quizAlreadyCompleted:
                showAlert(alertTitle: "Error",
                         message: "Quiz is already completed",
                         buttonTitle: "Okay")
                return .error
            }
        }
    }
    
    // Result enum for cleaner return values
    enum QuizQuestionResult {
        case moveToNext
        case quizCompleted
        case error
    }
    
    func toNextQuestion() {
        guard let quiz = chosenQuiz else { return }
        _ = quizManager.moveToNextQuestion(in: quiz)
    }
    
    // MARK: - Quiz Review
    
    func enterQuizReviewMode() {
        guard let quiz = chosenQuiz else { return }
        quizManager.enterReviewMode(for: quiz)
    }
    
    func checkAnswerToTheLeft() -> Bool {
        guard let quiz = chosenQuiz else {
            showAlert(alertTitle: "Error",
                     message: "No quiz selected",
                     buttonTitle: "Okay")
            return false
        }
        
        if !quizManager.moveToPreviousQuestion(in: quiz) {
            showAlert(alertTitle: "Error", 
                     message: "This is the first question.", 
                     buttonTitle: "Close")
            return false
        }
        return true
    }
    
    func checkAnswerToTheRight() -> QuizNavigationResult {
        guard let quiz = chosenQuiz else {
            showAlert(alertTitle: "Error",
                     message: "No quiz selected",
                     buttonTitle: "Okay")
            return .error
        }
        
        if !quizManager.moveToNextQuestionInReview(in: quiz) {
            return .endOfQuiz
        }
        return .success
    }
    
    // Result enum for navigation
    enum QuizNavigationResult {
        case success
        case endOfQuiz
        case error
    }
    
    // MARK: - Progress & Evaluation
    
    func calculateProgress() -> Double {
        guard let quiz = chosenQuiz else { return 0.0 }
        return quizManager.calculateProgress(in: quiz)
    }
    
    func calculateProgressString() -> String {
        guard let quiz = chosenQuiz else { return "0%" }
        return quizManager.calculateProgressString(in: quiz)
    }
    
    func calculateCurrentQuestionProgress() -> Double {
        guard let quiz = chosenQuiz else { return 0.0 }
        return quizManager.calculateCurrentQuestionProgress(in: quiz)
    }
    
    func evaluateAnswer() -> Bool {
        guard let quiz = chosenQuiz else { return false }
        return quizManager.isCurrentAnswerCorrect(in: quiz)
    }
    
    func hasUserPassedQuiz() -> Bool {
        guard let quiz = chosenQuiz else { return false }
        return quizManager.hasUserPassedQuiz(quiz)
    }
    
    func calculateScore() -> Int {
        guard let quiz = chosenQuiz else { return 0 }
        return quizManager.calculateScore(in: quiz)
    }
    
    // MARK: - Alert Management
    
    func showAlert(customError: Errors.BTError? = nil,
                   alertTitle: LocalizedStringResource = "Error",
                   message: LocalizedStringResource = "",
                   buttonTitle: LocalizedStringResource) {
        
        var alertMessage: String = ""
        
        if let customError {
            switch customError {
            case .networkError(let string):
                alertMessage = string
            case .invalidResponse(let string):
                alertMessage = string
            case .parseError(let string):
                alertMessage = string
            case .signUpError(let string):
                alertMessage = string
            case .logInError(let string):
                alertMessage = string
            case .forgotPasswordError(let string):
                alertMessage = string
            case .unknownError(let string):
                alertMessage = string
            }
        } else {
            alertMessage = message.key
        }
        let localizedMessage = LocalizedStringResource(stringLiteral: alertMessage)
        alertManager.showAlert(type: .error, title: alertTitle, message: localizedMessage, buttonText: buttonTitle, action: {})
    }
}

// MARK: - Sound and Haptics
extension QuizStore {
    
    func selectAnswerHaptic() {
        // Implementation for haptic feedback
    }
    
    func playCorrectSound() {
        // Implementation for sound feedback
    }
    
    func initCorrectHaptic() {
        // Implementation for haptic feedback
    }
}

// MARK: - Data Loading
extension QuizStore {
    
    /// Loads initial data (topics and quizzes)
    func loadInitialData(limit: Int? = nil) async throws {
        do {
            async let topicsTask = quizRepository.getTopics(limit: limit)
            async let quizzesTask = quizRepository.getQuizzes(limit: limit, offset: 0)
            
            let (topics, quizzes) = try await (topicsTask, quizzesTask)
            
            // Group quizzes by topic
            let quizzesByTopic = Dictionary(grouping: quizzes) { $0.topicId }
            
            // Update topics with their quizzes
            let updatedTopics = topics.map { topic in
                var updatedTopic = topic
                updatedTopic.quizes = quizzesByTopic[topic.id] ?? []
                return updatedTopic
            }
            
            // Update UI on main thread
            await MainActor.run {
                withAnimation {
                    self.allTopics = updatedTopics
                    self.allQuizez = quizzes
                }
            }
            
        } catch let error as QuizRepositoryError {
            await MainActor.run {
                self.showAlert(customError: error.toBTError(), buttonTitle: "Dismiss")
            }
        } catch {
            await MainActor.run {
                self.showAlert(alertTitle: "Error", 
                              message: "Unexpected error occurred", 
                              buttonTitle: "Dismiss")
            }
        }
    }
    
    /// Loads only quizzes with pagination support
    func getQuizzezOnly(limit: Int? = nil, offset: Int = 0) async throws {
        LoadingManager.shared.show()
        
        do {
            let quizzes = try await quizRepository.getQuizzes(limit: limit, offset: offset)
            
            await MainActor.run {
                withAnimation {
                    LoadingManager.shared.hide()
                    
                    if offset == 0 {
                        self.allQuizez = quizzes
                    } else {
                        self.allQuizez.append(contentsOf: quizzes)
                    }
                }
            }
            
        } catch let error as QuizRepositoryError {
            await MainActor.run {
                LoadingManager.shared.hide()
                self.showAlert(customError: error.toBTError(), buttonTitle: "Dismiss")
            }
        } catch {
            await MainActor.run {
                LoadingManager.shared.hide()
                self.showAlert(alertTitle: "Error", 
                              message: "Unexpected error occurred", 
                              buttonTitle: "Dismiss")
            }
        }
    }
    
    /// Loads more quizzes for pagination
    func loadMoreQuizzes(batchSize: Int = 10) async throws {
        let currentCount = allQuizez.count
        try await getQuizzezOnly(limit: batchSize, offset: currentCount)
    }
    
    /// Refreshes quizzes
    func refreshQuizzes(amount: Int = 10) async throws {
        try await getQuizzezOnly(limit: amount, offset: 0)
    }
    
    /// Loads first quiz for onboarding
    func loadOnboardingFirstQuiz(topicID: Int) async throws {
        do {
            guard let quiz = try await quizRepository.getQuizWithTopicID(topicID) else {
                throw QuizRepositoryError.quizFetchFailed("No quiz found for topic \(topicID)")
            }
            
            await MainActor.run {
                self.chosenQuiz = quiz
            }
            
        } catch let error as QuizRepositoryError {
            await MainActor.run {
                self.showAlert(customError: error.toBTError(), buttonTitle: "Dismiss")
            }
            throw error
        } catch {
            await MainActor.run {
                self.showAlert(alertTitle: "Error", 
                              message: "Failed to load quiz", 
                              buttonTitle: "Dismiss")
            }
            throw error
        }
    }
}


