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
    var chosenQuiz: Quiz?
    var chosenTopic: Topic?
    
// MARK: - Initialization
    
    init(supabase: Supabase) {
        #warning("Get userID from session. THE CORRECT WAY.")
        let userID: UUID = UUID(uuidString: UserDefaults.standard.string(forKey: "userID") ?? "") ?? .init()
        self.quizRepository = QuizRepository(supabase: supabase)
        self.quizManager = QuizManager(quizSessionService:QuizSessionService(supabaseClient: supabase.supabaseClient, userId: .init())) //TODO: Get userID from session.
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
    
    func startQuiz(onStart: @escaping () -> Void) {
        guard let unwrappedQuiz = chosenQuiz else {
            alertManager.showAlert(
                type: .error,
                message: "Unexpected Error, no quiz selected!",
                buttonText: "Go Back", action: {}
            )
            return
        }
        #warning("Fix this Task modifier. Should be async/await method and the caller should handle the async result.")
        Task {
            do {
                try await quizManager.startQuiz(unwrappedQuiz)
                onStart()
            } catch {
                print("❌ Error starting quiz: \(error)")
            }
        }
    }
    
    func quitQuiz(onQuit: @escaping () -> Void) {
        guard let unwrappedQuiz = chosenQuiz else {
            alertManager.showAlert(
                type: .error,
                message: "Unexpected Error, no quiz selected!",
                buttonText: "Go Back", action: {}
            )
            return
        }
        #warning("Fix this Task modifier. Should be async/await method and the caller should handle the async result.")
        
        Task {
            do {
                try await quizManager.exitQuiz(unwrappedQuiz)
                self.chosenQuiz = nil
                onQuit()
            } catch {
                print("❌ Error starting quiz: \(error)")
            }
        }
    }
    
// MARK: - Answer Management
    
    func selectAnswer(index: Int) {
        guard let quiz = chosenQuiz else { return }
        quizManager.selectAnswer(at: index, in: quiz)
    }
    
    func unselectAnswer(index: Int) {
        guard let quiz = chosenQuiz else { return }
        
        quizManager.unselectAnswer(at: index, in: quiz)
    }
    
// MARK: - Question Navigation
    
    func answerQuestion() -> QuizQuestionResult {
        guard let quiz = chosenQuiz else {
            alertManager.showAlert(
                    type: .error,
                    message: "No quiz selected",
                    buttonText: "Okay",
                    action: {}
            )
            return .error
        }
        
        let result = quizManager.submitCurrentQuestion(in: quiz)
        
        switch result {
        case .success(let action):
            switch action {
            case .moveToNext:
                return .moveToNext
            case .quizCompleted:
                #warning("Fix call to QuizManager. ASYNC Should not be used like this.... Look at self.startQuiz() method for reference.")
                Task {
                    try? await quizManager.completeQuiz(quiz)
                }
                return .quizCompleted
            }
        case .failure(let submissionError):
            switch submissionError {
            case .noAnswerSelected:
                alertManager.showAlert(
                    type: .warning,
                    message: "No answer selected!\nPlease select an answer",
                    buttonText: "Okay",
                    action: {}
                )
                return .error
            case .quizAlreadyCompleted:
                alertManager.showAlert(
                    type: .error,
                    message: "Quiz is already completed",
                    buttonText: "Okay",
                    action: {}
                )
                return .error
            }
        }
    }
    
    // Result enum for cleaner return values
   public enum QuizQuestionResult {
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
    
    func checkAnswerToTheLeft() {
        guard let quiz = chosenQuiz else {
            alertManager.showAlert(
                type: .error,
                message: "No quiz selected",
                buttonText: "Okay",
                action: {}
            )
          return
        }
        
        if !quizManager.moveToPreviousQuestion(in: quiz) {
            alertManager.showAlert(
                type: .error,
                message: "This is the first question.",
                buttonText: "Close",
                action: {}
            )
            return
        }
    }
    
    func checkAnswerToTheRight() -> QuizNavigationResult {
        guard let quiz = chosenQuiz else {
            alertManager.showAlert(
                type: .error,
                message: "No quiz selected",
                buttonText: "Okay",
                action: {}
            )
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
                self.alertManager.showBTErrorAlert(error.toBTError(), buttonTitle: "Dimiss", action: {})
            }
        } catch {
            await MainActor.run {
                self.unexpectedError()
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
                self.alertManager.showBTErrorAlert(error.toBTError(), buttonTitle: "Dimiss", action: {})
            }
        } catch {
            await MainActor.run {
                LoadingManager.shared.hide()
                self.unexpectedError()
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
                self.alertManager.showBTErrorAlert(error.toBTError(), buttonTitle: "Dimiss", action: {})
            }
            throw error
        } catch {
            await MainActor.run {
                alertManager.showAlert(
                    type: .error,
                    message: "Failed to load quiz",
                    buttonText: "Dismiss",
                    action: {}
                )
            }
            throw error
        }
    }
    
    private func unexpectedError() {
        alertManager.showAlert(
            type: .error,
            message: "Unexpected error occurred",
            buttonText: "Dismiss",
            action: {}
        )
    }
}


