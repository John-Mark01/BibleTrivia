//
//  DummySVM.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 12.10.24.
//

import Foundation

@Observable class DummySVM {
    
    static let shared = DummySVM()
    
    init() {
        self.populateRandomQuiz()
        self.populateRandomTopic()
        print("Init of DummySVM")
    }
    var topics: [Topic] = []
    var quizes: [Quiz] = []
    var chosenQuiz: Quiz?
    var tempQuiz: Quiz = Quiz(name: "Temporary test quiz", questions: [
        Question(text: "This is question 1", answers: [
            Answer(isCorrect: false, isSelected: false, text: "This is answer  1"),
            Answer(isCorrect: false, isSelected: false, text: "This is answer  2"),
            Answer(isCorrect: true, isSelected: false, text: "This is answer  3"),
            Answer(isCorrect: false, isSelected: false, text: "This is answer  4"),
        ], explanation: "How can this be so complicated bruh..."),
        Question(text: "This is question 2", answers: [
            Answer(isCorrect: false, isSelected: false, text: "This is answer  1"),
            Answer(isCorrect: false, isSelected: false, text: "This is answer  2"),
            Answer(isCorrect: true, isSelected: false, text: "This is answer  3"),
            Answer(isCorrect: false, isSelected: false, text: "This is answer  4"),
        ], explanation: "How can this be so complicated bruh...")
    ], time: 2, status: .new, difficulty: .newBorn, totalPoints: 20)
    
    
    private func generateRandomTopicName() -> String {
        let names = ["New Testement", "Old Testement", "Moses", "Apostle Paul", "Jesus", "God the Father", "Holy Spirit"]
        return names.randomElement() ?? ""
     }
    
   private func generateRandomQuizName() -> String {
       let names = ["New Testement", "Old Testement", "Ephesians", "Paul's Messages", "Jesus of Nazareth", "The Trinity", "Apostole Peter"]
       return names.randomElement() ?? ""
    }
    private func generateRandomQuestionNames() -> String {
        let names = ["How did Jesus die", "What was the name of first Apostle", "What was Jesus's first mircale", "How much time did Moses strangle in the desert", "What does 'Mesiah' mean", "Who was Abraham", "Apostole Peter was not jewish"]
       return names.randomElement() ?? ""
    }
    private func generateRandomAnswerNames() -> String {
        let names = ["On the cross", "John", "Turning water into wine", "40 years", "The saviour", "God's friend", "False", "True"]
       return names.randomElement() ?? ""
    }
    
    
    
    private func generateRandomDificulty() -> DifficultyLevel {
        return DifficultyLevel.allCases.randomElement() ?? .newBorn
    }
    
    private func generateRandomCorrect() -> Bool {
        let isCorrect: Bool = Bool.random()
        return isCorrect
    }
    
    private func generateRandomQuestions() -> [Question] {
        var questions: [Question] = []
        var answers: [Answer] = []
        for _ in 0..<4 {
            let answer = Answer(isCorrect: self.generateRandomCorrect(), isSelected: false, text: self.generateRandomAnswerNames())
            answers.append(answer)
        }
        for _ in 0..<4 {
            let newQuestion = Question(text: self.generateRandomQuestionNames(), answers: answers, explanation: "Nothing")
            
            questions.append(newQuestion)
        }
        
        return questions
    }
    
    private func populateRandomQuiz() {
        
        for _ in 0..<10 {
            let quiz = Quiz(name: self.generateRandomQuizName(), questions: self.generateRandomQuestions(), time: 1234543, status: .new, difficulty: self.generateRandomDificulty(), totalPoints: 150)
            
            self.quizes.append(quiz)
        }
        
    }
    private func populateRandomTopic() {
        
        for _ in 0..<5 {
            let topic = Topic(name: self.generateRandomTopicName(), quizes: self.quizes)
            self.topics.append(topic)
        }
        
    }
}
