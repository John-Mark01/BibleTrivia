//
//  DummySVM.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 12.10.24.
//

import Foundation

@Observable class DummySVM {
    
    let topics: [Topic] = []
    let quizes: [Quiz] = []
    
    
   private func generateRandomName() -> String {
       let names = ["New Testement", "Old Testement", "Ephesians", "Paul's Messages", "Jesus of Nazareth", "The Trinity", "Apostole Peter"]
       return names.randomElement() ?? ""
    }
    
    private func generateRandomDificulty() -> DifficultyLevel {
        return DifficultyLevel.allCases.randomElement() ?? .newBorn
    }
    
    private func generateRandomQuestions() -> [Question] {
        var questions: [Question] = []
        
        for question in 0..<4 {
            let newQuestion = Question(isCorrect: false, isSelected: false, answer: "How Did Jesus Reign")
            
            questions.append(newQuestion)
        }
        
        return questions
    }
}
