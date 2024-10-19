//
//  QuizManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 16.10.24.
//

import Foundation

@Observable class QuizStore {
    
    // inject the Database here to get and store everything about each quiz
    
    // Both of theese will be populated from the DataBase
    var allTopics: [Topic] = []
    var allQuizez: [Quiz] = []
    var startedQuizez: [Quiz] = []
    
    var chosenQuiz: Quiz?
    
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
        if var unwrappedQuiz = chosenQuiz {
            unwrappedQuiz.status = .started
            unwrappedQuiz.currentQuestionIndex = 0
            
            startedQuizez.append(unwrappedQuiz)
            onStart(true)
        } else {
            onStart(false)
            //TODO: Create custom alert with - "Unexpected Error, no quiz selected!"
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
    func answerQuestion(finished: @escaping (Bool) -> Void) {
        if let selectedAnswer = chosenQuiz?.currentQuestion.answers.first(where: { $0.isSelected }) {
            chosenQuiz?.currentQuestion.userAnswer = selectedAnswer
        } else {
            print("Unexpected Error, No answer is selected!")
            //TODO: Create custom alert with - "Unexpected Error, No answer is selected!",                                                      "Please select an answer!"
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
