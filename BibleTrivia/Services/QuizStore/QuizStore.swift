//
//  QuizStore.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 16.10.24.
//

import Foundation
import SwiftUI

@MainActor
@Observable final class QuizStore: RouterAccessible, AuthenticatedStore {
    
// MARK: - Dependencies
    private let quizRepository: QuizRepositoryProtocol
    private let quizManager: QuizManager
    let alertManager: AlertManager
    var userId: UUID?
    
// MARK: - State Properties
    var allTopics: [Topic] = []
    var allQuizez: [Quiz] = []
    private(set) var chosenQuiz: Quiz?
    private(set) var chosenTopic: Topic?
    
// MARK: - Initialization
    
    init(supabase: Supabase) {
        self.quizRepository = QuizRepository(supabase: supabase)
        self.quizManager = QuizManager(supabaseClient: supabase.supabaseClient)
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
        guard let quiz = self.chosenQuiz else {
            alertManager.showAlert(
                type: .error,
                message: "Unexpected Error, no quiz is selected!",
                buttonText: "Go Back", action: { self.router.popBackStack() }
            )
            return Quiz()
        }
        
        return quiz
    }
    
// MARK: - Authentication
    /// Call this after user authenticates to set up the store
    func setUserId(_ id: UUID) {
        self.userId = id
    }
    
// MARK: - Quiz Selection & Management
    
    func chooseQuiz(quiz: Quiz) {
        log(with: "❗️ User is chosing quiz with name: \(quiz.name)")
        self.chosenQuiz = quiz
    }
    
    func cancelChoosingQuiz(onCancel: @escaping () -> Void) {
        onCancel()
        log(with: "❗️ User is canceling quiz with name: \(chosenQuiz?.name ?? "")")
        self.chosenQuiz = nil
    }
    
    func startQuiz(onStart: @escaping () -> Void) async {
        guard let userId = requireAuthentication() else { return }
        
        guard let unwrappedQuiz = chosenQuiz else {
            alertManager.showAlert(
                type: .error,
                message: "Unexpected Error, no quiz selected!",
                buttonText: "Go Back", action: { self.router.popBackStack() }
            )
            return
        }
        
        guard unwrappedQuiz.questions.isEmpty == false else {
            alertManager.showAlert(
                type: .error,
                message: "Unexpected Error, no questions populated in quiz!",
                buttonText: "Go Back", action: {}
            )
            return
        }
        
        do {
            try await quizManager.startQuiz(unwrappedQuiz, userId: userId)
            log(with: "✅ User starts quiz - '\(unwrappedQuiz.name)'")
            onStart()
        } catch {
            alertManager.showAlert(
                type: .error,
                message: "Coudn't start quiz. Please try again",
                buttonText: "Dismiss",
                action: {}
            )
            log(with: "❌ Error starting quiz: \(error.localizedDescription)")
        }
    }
    
    func quitQuiz(onQuit: @escaping (StartedQuiz) -> Void) async {
        guard let userId = requireAuthentication() else { return }
        
        guard let unwrappedQuiz = chosenQuiz else {
            alertManager.showAlert(
                type: .error,
                message: "Unexpected Error, no quiz selected!",
                buttonText: "Go Back", action: { self.router.popBackStack() }
            )
            return
        }
        
        do {
            try await quizManager.exitQuiz(unwrappedQuiz, userId: userId) { [weak self] sesionId in
                onQuit(StartedQuiz(sessionId: sesionId, quiz: unwrappedQuiz))
                self?.log(with: "✅ User quits quiz - '\(unwrappedQuiz.name)'")
            }
        } catch {
            alertManager.showAlert(
                type: .error,
                message: "Coudn't quit quiz. Please try again",
                buttonText: "Dismiss",
                action: {}
            )
            log(with: "❌ Error quiting quiz: \(error.localizedDescription)")
        }
    }
    
    func resumeQuiz(_ quiz: Quiz, from sessionId: Int) async {
        guard let userId = requireAuthentication() else { return }
        
        let quiz = await quizManager.resumeQuiz(quiz: quiz, userId: userId, sessionId: sessionId)
        self.chosenQuiz = quiz
        log(with: "✅ Resuming Quiz with name: \(quiz?.name ?? "")")
    }
    
    func completeQuiz(onComplete: @escaping (CompletedQuiz) async -> Void) async {
        guard let userId = requireAuthentication() else { return }
        guard let unwrappedQuiz = chosenQuiz else {
            alertManager.showAlert(
                type: .error,
                message: "Unexpected Error, no quiz selected!",
                buttonText: "Go Back", action: { self.router.popBackStack() }
            )
            return
        }
        
        do {
            guard let completedQuiz = try await quizManager.completeQuiz(unwrappedQuiz, userId: userId) else {
                alertManager.showAlert(
                    type: .error,
                    message: "Couldn't complete quiz. Please try again.",
                    buttonText: "Dismiss",
                    action: {}
                )
                log(with: "❌ Couldn't unwrap completed quiz.")
                return
            }
            log(with: "✅ Quiz with name: \(completedQuiz.quiz.name) completed.")
            await onComplete(completedQuiz)
        } catch {
            alertManager.showAlert(
                type: .error,
                message: "Coudn't complete quiz. Please try again",
                buttonText: "Dismiss",
                action: {}
            )
            log(with: "❌ Error completing quiz: \(error.localizedDescription)")
        }
    }
    
    func removeQuizFromStore(_ quiz: Quiz) {
        guard allQuizez.contains(where: { $0.id == quiz.id }) else { return }
        self.allQuizez.removeAll { $0.id == quiz.id }
        self.chosenQuiz = nil
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
                message: "Unexpected Error, no quiz selected!",
                buttonText: "Go Back", action: { self.router.popBackStack() }
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
    
//    func calculateProgress() -> Double {
//        guard let quiz = chosenQuiz else { return 0.0 }
//        return quizManager.calculateProgress(in: quiz)
//    }
    
    func calculateCurrentQuestionProgress() -> Double {
        guard let quiz = chosenQuiz else { return 0.0 }
        return quizManager.calculateCurrentQuestionProgress(in: quiz)
    }
    
    func hasUserPassedQuiz() -> Bool {
        guard let quiz = chosenQuiz else { return false }
        return quizManager.hasUserPassedQuiz(quiz)
    }
}

// MARK: - Data Loading
extension QuizStore {
    
    /// Loads initial data (topics and quizzes)
    func loadInitialData(limit: Int? = nil) async {
        guard let userId = requireAuthentication() else { return }
        LoadingManager.shared.show()
        
        do {
            async let topicsTask = quizRepository.getTopics(limit: limit)
            async let quizzesTask = quizRepository.getQuizzes(userId: userId, limit: limit, offset: 0)
            
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
                    LoadingManager.shared.hide()
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
    private func getQuizzezOnly(limit: Int? = nil, offset: Int = 0) async {
        guard let userId = requireAuthentication() else { return }
        
        LoadingManager.shared.show()
        do {
            let quizzes = try await quizRepository.getQuizzes(userId: userId, limit: limit, offset: offset)
            
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
    func loadMoreQuizzes(batchSize: Int = 10) async {
        let currentCount = allQuizez.count
        await getQuizzezOnly(limit: batchSize, offset: currentCount)
    }
    
    /// Refreshes quizzes
    func refreshQuizzes(amount: Int = 10) async {
        await getQuizzezOnly(limit: amount, offset: 0)
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
    
    private func log(with message: String) {
        print("🟡 QuizStore: \(message)\n")
    }
}
