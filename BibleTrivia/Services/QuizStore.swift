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
    // inject the Database here to get and store everything about each quiz
    var supabase: Supabase
    
    init(supabase: Supabase) {
        self.supabase = supabase
        print("\(self) is initialized")
    }
        
        func loadQuizData(limit: Int? = nil, offset: Int = 0) async throws {
            LoadingManager.shared.show()
            // Start fetches concurrently with parameters
            do {
                async let topicsTask = supabase.getTopics()
                async let quizzesTask = supabase.getQuizzez(limit: limit, offset: offset)
                async let questionsTask = supabase.getQuestions(for: 7)
                async let answersTask = supabase.getAnswers()
                
                let (topics, quizzes, questions, answers) = try await (topicsTask, quizzesTask, questionsTask, answersTask)
                
                let answersDict = Dictionary(grouping: answers) { $0.questionId }
                let questionsDict = Dictionary(grouping: questions) { $0.quizId }
                let quizzesByTopic = Dictionary(grouping: quizzes) { $0.topicId }
                
                let updatedQuizzes = quizzes.map { quiz in
                    let updatedQuiz = quiz
                    if let quizQuestions = questionsDict[quiz.id] {
                        let questionsWithAnswers = quizQuestions.map { question in
                            var updatedQuestion = question
                            updatedQuestion.answers = answersDict[question.id] ?? []
                            return updatedQuestion
                        }
                        updatedQuiz.questions = questionsWithAnswers
                    }
                    return updatedQuiz
                }
                
                // Then, update topics with their quizzes
                let updatedTopics = topics.map { topic in
                    var updatedTopic = topic
                    updatedTopic.quizes = quizzesByTopic[topic.id] ?? []
                    return updatedTopic
                }
                
                // Update the UI
                withAnimation {
                    LoadingManager.shared.hide()
                    // Append or replace based on offset
                    if offset == 0 {
                        self.allQuizez = updatedQuizzes
                        self.allTopics = updatedTopics
                    } else {
                        self.allQuizez.append(contentsOf: updatedQuizzes)
                        self.allTopics.append(contentsOf: updatedTopics)
                    }
                }
            } catch let error as Errors.SupabaseError {
                LoadingManager.shared.hide()
                print("Error in QuizStore.loadQuizData:\n\(error)")
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
            try await loadQuizData(limit: batchSize, offset: currentCount)
        }
        
        // For refreshing
        func refreshQuizzes(amount: Int = 10) async throws {
            try await loadQuizData(limit: amount, offset: 0)
        }
  
    // Both of theese will be populated from the DataBase
    var allTopics: [Topic] = []
    var allQuizez: [Quiz] = [Quiz(id: 0, name: "When initialized", topicId: 3, time: 2, status: 2, difficulty: 2, totalPoints: 240)]
    var startedQuizez: [Quiz] = []
    
    var chosenQuiz: Quiz?
    var chosenTopic: Topic?
    var showAlert: Bool = false
    var alertTitle: String = ""
    var alertMessage: String = ""
    var alertButtonTitle: String = ""
    
    var reviewQuestions: [Question] = []
    
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
        print("Answer - \(chosenQuiz!.currentQuestion.answers[index].text)")
        chosenQuiz?.currentQuestion.answers[index].isSelected = true
        print("Selected - \(chosenQuiz!.currentQuestion.answers[index].isSelected)")
        chosenQuiz?.questionNumber += 1
        selectAnswerHaptic()
    }
    func unSelectAnswer(index: Int) {
        print("Answer - \(chosenQuiz!.currentQuestion.answers[index].text)")
        chosenQuiz?.currentQuestion.answers[index].isSelected = false
        print("Unselected - \(chosenQuiz!.currentQuestion.answers[index].isSelected)")
        chosenQuiz?.questionNumber -= 1
        selectAnswerHaptic()
    }
    
    // When clicked on Next
    func answerQuestion(finished: @escaping (Bool) -> Void, error: @escaping (Bool) -> Void) {
        if let selectedAnswer = chosenQuiz?.currentQuestion.answers.first(where: { $0.isSelected }) {
            chosenQuiz?.currentQuestion.userAnswer = selectedAnswer
        } else {
            print("Unexpected Error, No answer is selected!")
            alertTitle = "Warning"
            alertMessage = "No answer selected!\nPlease select an answer"
            alertButtonTitle = "Okay"
            error(true)
            return
        }
        
        if evaluateAnswer() {
            answerIsCorrect()
        } else {
            answerIsWrong()
        }
        
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
    // Helper functions on user answer submition
    func answerIsCorrect() {
        print("Answer Is Correct - \(chosenQuiz?.currentQuestion.userAnswer?.text ?? "")")
        self.chosenQuiz?.totalPoints += 10
        self.playCorrectSound()
        self.initCorrectHaptic()
    }
    
    func answerIsWrong() {
        print("Answer Is Wrong - \(chosenQuiz?.currentQuestion.userAnswer?.text ?? "")")
        self.playCorrectSound()
        self.initCorrectHaptic()
        
    }
    
    // Goes to the next question in the Quiz.questions Array
    func toNextQuestion() {
        if self.chosenQuiz!.currentQuestionIndex <=  self.chosenQuiz!.numberOfQuestions {
            self.chosenQuiz?.currentQuestionIndex += 1
        }
    }
    
    func finishQuiz() {
        if let quiz = self.chosenQuiz {
            quiz.isFinished = true
            // Adds the finished Quiz to the User's Quizzez
            if !UserModel.shared.completedQuizzes.contains(where: { $0.id == quiz.id }) {
                UserModel.shared.completedQuizzes.append(quiz)
            }
        }
        
        print("Total Completed Quizzes: \(UserModel.shared.completedQuizzes.count)")
    }
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
            self.showAlert(alertTtitle: "Error", message: "This is the last question.", buttonTitle: "Close")
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
    func showAlert(customError: Errors.SupabaseError? = nil,
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
