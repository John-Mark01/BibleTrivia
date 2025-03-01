//
//  OnboardingManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 19.01.25.
//

import Foundation

@Observable class OnboardingManager {
    
    var newUserEmail: String = ""
    var newUserCountry: String = "" //TODO: Can be an object
    var newUserAge: String = ""
    var newUserName: String = ""
    var newUserPassword: String = ""
    var newUserPasswordConfirmation: String = ""
    
    
    var didYouKnowScreenCount: Int = 1
    var didYouKnowIsShown: Bool = false
    
    init() {
        loadSurvey()
    }
    var survey = Quiz(name: "survey", questions: [], time: 1, status: .new, difficulty: .newBorn, totalPoints: 0)

    func getAnswerABC(index: Int) -> String {
        switch index {
        case 0:
            return "A"
        case 1:
            return "B"
        case 2:
            return "C"
        case 3:
            return "D"
        default:
            return "A"
        }
    }
    
    func loadSurvey() {
        let answers1: [Answer] = [
            Answer(id: 1, text: "Not so much", questionId: 0, isCorrect: false),
            Answer(id: 2, text: "Sunday school knowledge", questionId: 0, isCorrect: false),
            Answer(id: 3, text: "Pretty well", questionId: 0, isCorrect: false),
            Answer(id: 4, text: "I'm a Scholar", questionId: 0, isCorrect: false)
        ]
        let answers2: [Answer] = [
            Answer(id: 1, text: "0-2 weekly", questionId: 0, isCorrect: false),
            Answer(id: 2, text: "2-3 weekly", questionId: 0, isCorrect: false),
            Answer(id: 3, text: "3-5 weekly", questionId: 0, isCorrect: false),
            Answer(id: 4, text: "Every day", questionId: 0, isCorrect: false)
        ]
        let answers3: [Answer] = [
            Answer(id: 1, text: "New Testement", questionId: 0, isCorrect: false),
            Answer(id: 2, text: "Old Testement", questionId: 0, isCorrect: false),
            Answer(id: 3, text: "Bible Characters", questionId: 0, isCorrect: false),
            Answer(id: 4, text: "Geography", questionId: 0, isCorrect: false)
        ]
        let answers4: [Answer] = [
            Answer(id: 1, text: DifficultyLevel.newBorn.getAsString(), questionId: 0, isCorrect: false),
            Answer(id: 2, text: DifficultyLevel.sundaySchool.getAsString(), questionId: 0, isCorrect: false),
            Answer(id: 3, text: DifficultyLevel.youthPastor.getAsString(), questionId: 0, isCorrect: false),
            Answer(id: 4, text: DifficultyLevel.deacon.getAsString(), questionId: 0, isCorrect: false),
            Answer(id: 5, text: DifficultyLevel.seniorPastor.getAsString(), questionId: 0, isCorrect: false)
        ]
        
        let question1 = Question(text: "How well do you know the Bible?", explanation: "", answers: answers1)
        
        let question2 = Question(text: "How often do you read the Bible?", explanation: "", answers: answers2)
        
        let question3 = Question(text: "What topics do you like the most?", explanation: "", answers: answers3)
        
        let question4 = Question(text: "What would you say your level is?", explanation: "", answers: answers4)
        
        self.survey.questions = [question1, question2, question3, question4]
    }
}
