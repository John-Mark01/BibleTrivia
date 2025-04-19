//
//  QuizManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 16.10.24.
//

import Foundation
import SwiftUI

@MainActor
@Observable class QuizStore {
    
    var supabase: Supabase
    var alertManager: AlertManager
    
    init(supabase: Supabase) {
        self.supabase = supabase
        self.alertManager = AlertManager.shared
    }
    
    var allTopics: [Topic] = []
    var allQuizez: [Quiz] = [Quiz(id: 0, name: "When initialized", topicId: 3, time: 2, status: 2, difficulty: 2, totalPoints: 240)]
    
    var startedQuizez: [Quiz] = []
    var chosenQuiz: Quiz?
    var chosenTopic: Topic?
    var isOnboardingQuiz: Bool = false
    
    
    var showAlert: Bool = false  
    var alertTitle: String = ""
    var alertMessage: String = ""
    var alertButtonTitle: String = ""
    
    // Computed property for safe quiz access
    var currentQuiz: Quiz {
        guard let quiz = chosenQuiz else {
            return Quiz(id: 0, name: "Error", topicId: 0, time: 0, status: 0, difficulty: 0, totalPoints: 0)
        }
        return quiz
    }
    
    // When clicked on a certain quiz
    func chooseQuiz(quiz: Quiz) {
        self.chosenQuiz = quiz
    }
    
    // When clicked on Cancel, when modal shows up
    func cancelChoosingQuiz(onCancel: @escaping () -> Void) {
        self.chosenQuiz = nil
        onCancel()
    }
    
    // When clicked on Start, when modal shows up
    func startQuiz(onStart: @escaping (Bool) -> Void) {
        if let unwrappedQuiz = chosenQuiz {
            unwrappedQuiz.status = .started
            unwrappedQuiz.currentQuestionIndex = 0
            
            startedQuizez.append(unwrappedQuiz)
            onStart(true)
        } else {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Unexpected Error, no quiz selected!"
            alertButtonTitle = "Go Back"
            onStart(false)
            showAlert = false
        }
    }
    
    // When clicked on any answer
    func selectAnswer(index: Int) {
        let questionIndex = chosenQuiz?.currentQuestionIndex ?? 0
        
        if (chosenQuiz?.questions[questionIndex].answers.filter({$0.isSelected}).count)! > 0 {
            return
        }
        
        chosenQuiz?.currentQuestion.answers[index].isSelected = true
        selectAnswerHaptic()
    }
    func unSelectAnswer(index: Int) {
        chosenQuiz?.currentQuestion.answers[index].isSelected = false
        selectAnswerHaptic()
    }
    
    // When clicked on Next
    func answerQuestion(finished: @escaping (Bool) -> Void,
                        error: @escaping (Bool) -> Void) {
        
        if let selectedAnswer = chosenQuiz?.currentQuestion.answers.first(where: { $0.isSelected }) {
            chosenQuiz?.currentQuestion.userAnswer = selectedAnswer
        } else {
            alertTitle = "Warning"
            alertMessage = "No answer selected!\nPlease select an answer"
            alertButtonTitle = "Okay"
            error(true)
            return
        }
        
//        if evaluateAnswer() {
//            answerIsCorrect()
//        } else {
//            answerIsWrong()
//        }
        
        if self.chosenQuiz!.currentQuestionIndex + 1 < self.chosenQuiz!.numberOfQuestions {
            finished(false)
        } else {
            finished(true)
        }
    }
    // This function Evaluates the answer of the user
    func evaluateAnswer() -> Bool {
        if let answer = chosenQuiz?.currentQuestion.userAnswer {
            if answer.isCorrect {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    // Goes to the next question in the Quiz.questions Array
    func toNextQuestion() {
        if self.chosenQuiz!.currentQuestionIndex <=  self.chosenQuiz!.numberOfQuestions {
            self.chosenQuiz?.currentQuestionIndex += 1
        }
    }
    //TODO: NEed another way to finish quiz
//    func finishQuiz() {
//        if let quiz = self.chosenQuiz {
//            quiz.isFinished = true
//            // Adds the finished Quiz to the User's Quizzez
//            if !UserModel.shared.completedQuizzes.contains(where: { $0.id == quiz.id }) {
//                UserModel.shared.completedQuizzes.append(quiz)
//            }
//        }
//        
//        print("Total Completed Quizzes: \(UserModel.shared.completedQuizzes.count)")
//    }
    //MARK: Quiz Review after finishing the quiz
    func checkAnswerToTheLeft(error: @escaping (Bool) -> Void) {
        guard let chosenQuiz else {return}
        
        let currentQuestionIndex = chosenQuiz.currentQuestionIndex
        if currentQuestionIndex <= 0 {
            self.showAlert(alertTtitle: "Error", message: "This is the last question.", buttonTitle: "Close")
            error(true)
        } else {
            self.chosenQuiz?.currentQuestionIndex -= 1
        }
    }
    func checkAnswerToTheRight(error: @escaping () -> Void) {
        guard let chosenQuiz else {return}
        
        let currentQuestionIndex = chosenQuiz.currentQuestionIndex
        if currentQuestionIndex+1 >= chosenQuiz.numberOfQuestions {
            error()
        } else {
            self.chosenQuiz?.currentQuestionIndex += 1
        }
    }
    
    func enterQuizReviewMode() {
        self.chosenQuiz?.isInReview = true
    }
    
    // When clicked on Cancel, when modal shows up
    func quitQuiz(onQuit: @escaping () -> Void) {
        self.chosenQuiz = nil
        onQuit()
    }
    
    //MARK: Helpers
    func showAlert(customError: Errors.BTError? = nil,
                   alertTtitle: String = "Error",
                   message: String = "",
                   buttonTitle: String) {
        
        if let customError {
            var alertMessage: String = ""
            
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
            self.alertMessage = alertMessage
        } else {
            self.alertMessage = message
        }
        
        self.showAlert = true
        self.alertTitle = alertTtitle
        self.alertButtonTitle = buttonTitle
    }
}

//MARK: Sound and Haptics
extension QuizStore {
    
    func selectAnswerHaptic() {
        
    }
    
    func playCorrectSound() {
        
    }
    
    func initCorrectHaptic() {
        
    }
}



//MARK: Database
extension QuizStore {
    
    // Fetching all of the Topics, Quizzez, Questions and Answers from the database
    func loadInitialData(limit: Int? = nil) async throws {
        // Start fetches concurrently with parameters
        do {
            async let topicsTask = supabase.getTopics(limit: limit)
            async let quizzesTask = self.getQuizzez(limit: limit)
            
            
            let (topics, quizzes) = try await (topicsTask, quizzesTask)
            
            let quizzesByTopic = Dictionary(grouping: quizzes) { $0.topicId }
            
            
            // Then, update topics with their quizzes
            let updatedTopics = topics.map { topic in
                var updatedTopic = topic
                updatedTopic.quizes = quizzesByTopic[topic.id] ?? []
                return updatedTopic
            }
            
            // Update the UI
            withAnimation {
                self.allTopics = updatedTopics
                self.allQuizez = quizzes
            }
            
        } catch let error as Errors.BTError {
            print("Error in QuizStore.loadInitalData:\n\(error)")
            self.showAlert(customError: error, buttonTitle: "Dismiss")
        } catch {
            print(error.localizedDescription)
            self.showAlert(alertTtitle: "Error", message: "Unexpected error...", buttonTitle: "Dismiss")
        }
    }
    
    func getQuizzezOnly(limit: Int? = nil, offset: Int = 0) async throws {
        LoadingManager.shared.show()
        do {
            let quizzez = try await getQuizzez(limit: limit, offset: offset)
            
            // Update the UI
            withAnimation {
                LoadingManager.shared.hide()
                // Append or replace based on offset
                if offset == 0 {
                    self.allQuizez = quizzez
                } else {
                    self.allQuizez.append(contentsOf: quizzez)
                }
            }
            
        } catch let error as Errors.BTError {
            LoadingManager.shared.hide()
            self.showAlert(customError: error, buttonTitle: "Dismiss")
        } catch {
            LoadingManager.shared.hide()
            print(error.localizedDescription)
            self.showAlert(alertTtitle: "Error", message: "Unexpected error...", buttonTitle: "Dismiss")
        }
        
    }
    
    // For pagination
    func loadMoreQuizzes(batchSize: Int = 10) async throws {
        let currentCount = allQuizez.count
        try await getQuizzezOnly(limit: batchSize, offset: currentCount)
    }
    
    // For refreshing
    func refreshQuizzes(amount: Int = 10) async throws {
        try await getQuizzezOnly(limit: amount, offset: 0)
    }
    
    private func getQuizzez(limit: Int? = nil, offset: Int = 0) async throws -> [Quiz] {
        do {
            // Get quizzes
            let quizzes = try await supabase.getQuizzez(limit: limit, offset: offset)
            
            // Fill each quiz's questions directly
            for index in 0..<quizzes.count {
                let questions = try await fillQuizData(quizId: quizzes[index].id)
                quizzes[index].questions = questions
            }
            
            return quizzes
            
        } catch _ as Errors.BTError {
            throw Errors.BTError.parseError("Couldn't get quizzes")
        } catch {
            throw Errors.BTError.unknownError("Unknown error. Please contact us.")
        }
    }
    private func fillQuizData(quizId: Int) async throws -> [Question] {
        // Get questions
        do {
            let questions = try await supabase.getQuestions(for: quizId)
            let questionIds = questions.map { $0.id }
            let answers = try await supabase.getAnswers(for: questionIds)
            
            // Get answers for each question
            let answersDict = Dictionary(grouping: answers) { $0.questionId }
            
            // Add answers to their questions
            let questionsWithAnswers = questions.map { question in
                var updatedQuestion = question
                updatedQuestion.answers = answersDict[question.id] ?? []
                return updatedQuestion
            }
            
            return questionsWithAnswers
        } catch {
            throw Errors.BTError.parseError("Couldn't fetch Quiz data. Please try again later.")
        }
    }
    
    
//MARK: FirstQuiz uppon onboarding
    func loadOnboardingFirstQuiz(topicID: Int) async throws {
        do {
            if let quiz = try await supabase.getQuizWithTopicID(topicID) {
                
                let questions = try await fillQuizData(quizId: quiz.id)
                quiz.questions = questions
                self.chosenQuiz = quiz
                self.isOnboardingQuiz = true
            } else {
                throw Errors.BTError.parseError("Couldn't fetch Quiz data. Please try again later.")
            }
        } catch {
            throw Errors.BTError.parseError("Couldn't fetch Quiz data. Please try again later.")
        }
    }
}

