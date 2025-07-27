////
////  DummySVM.swift
////  BibleTrivia
////
////  Created by John-Mark Iliev on 12.10.24.
////
//
//import Foundation
//
//@Observable class DummySVM {
//    
//    static let shared = DummySVM()
//    
//    init() {
//        self.populateRandomQuiz()
//        self.populateRandomTopic()
//        print("Init of DummySVM")
//    }
//    var topics: [Topic] = []
//    var quizes: [Quiz] = []
//    var chosenQuiz: Quiz?
//    var tempQuiz: Quiz = Quiz(name: "Apostle Paul", questions: [
//        Question(text: "How many books did the apostle wrote", explanation: "14", answers: [
//            Answer(isCorrect: true, isSelected: false, text: "14"),
//            Answer(isCorrect: false, isSelected: false, text: "12"),
//            Answer(isCorrect: false, isSelected: false, text: "11"),
//            Answer(isCorrect: false, isSelected: false, text: "7"),
//        ], userAnswer: nil),
//        Question(text: "How much time did the apostle was blind", explanation: "3", answers: [
//            Answer(isCorrect: false, isSelected: false, text: "4 days"),
//            Answer(isCorrect: false, isSelected: false, text: "He was blind forever"),
//            Answer(isCorrect: true, isSelected: false, text: "3 days"),
//            Answer(isCorrect: false, isSelected: false, text: "2 days"),
//        ], userAnswer: nil),
//        Question(text: "After how many years did the apostle met the other apostles", explanation: "14", answers: [
//            Answer(isCorrect: false, isSelected: false, text: "10 years"),
//            Answer(isCorrect: false, isSelected: false, text: "7 years"),
//            Answer(isCorrect: false, isSelected: false, text: "3 days"),
//            Answer(isCorrect: true, isSelected: false, text: "14 years"),
//        ], userAnswer: nil),
//        Question(text: "Did ap.Paul met Jesus in person?", explanation: "No", answers: [
//            Answer(isCorrect: false, isSelected: false, text: "Yes"),
//            Answer(isCorrect: true, isSelected: false, text: "No"),
//            Answer(isCorrect: false, isSelected: false, text: "The Bible doesn't say"),
//        ], userAnswer: nil),
//        Question(text: "On which Island did the apostle Paul shipwrecked?", explanation: "Malta", answers: [
//            Answer(isCorrect: true, isSelected: false, text: "Malta"),
//            Answer(isCorrect: false, isSelected: false, text: "Rome"),
//            Answer(isCorrect: false, isSelected: false, text: "Greek Island"),
//            Answer(isCorrect: false, isSelected: false, text: "He never had a shipwreck")
//        ], userAnswer: nil),
//        Question(text: "Is ap.Paul a Jew?", explanation: "Yes", answers: [
//            Answer(isCorrect: false, isSelected: false, text: "The Bible doesn't say"),
//            Answer(isCorrect: true, isSelected: false, text: "Yes"),
//            Answer(isCorrect: false, isSelected: false, text: "No"),
//            Answer(isCorrect: false, isSelected: false, text: "He is actually a Gentile")
//        ], userAnswer: nil),
//        Question(text: "How many times did ap.Paul go on a missionary journey?", explanation: "4", answers: [
//            Answer(isCorrect: false, isSelected: false, text: "1"),
//            Answer(isCorrect: false, isSelected: false, text: "2"),
//            Answer(isCorrect: false, isSelected: false, text: "3"),
//            Answer(isCorrect: true, isSelected: false, text: "4"),
//        ], userAnswer: nil),
//        Question(text: "The apostole died on a cross?", explanation: "No", answers: [
//            Answer(isCorrect: false, isSelected: false, text: "Yes"),
//            Answer(isCorrect: true, isSelected: false, text: "No")
//        ], userAnswer: nil),
//        Question(text: "Did ap.Paul had family?", explanation: "No", answers: [
//            Answer(isCorrect: true, isSelected: false, text: "No"),
//            Answer(isCorrect: false, isSelected: false, text: "The Bible doesn't say")
//        ], userAnswer: nil),
//        Question(text: "Did ap.Paul ever sinned?", explanation: "Yes", answers: [
//            Answer(isCorrect: false, isSelected: false, text: "The Bible doesn't say"),
//            Answer(isCorrect: true, isSelected: false, text: "Yes"),
//            Answer(isCorrect: false, isSelected: false, text: "No")
//        ], userAnswer: nil)
//    ], time: 2, status: .new, difficulty: .youthPastor, totalPoints: 20)
//    
//    
//    private func generateRandomTopicName() -> String {
//        let names = ["New Testement", "Old Testement", "Moses", "Apostle Paul", "Jesus", "God the Father", "Holy Spirit"]
//        return names.randomElement() ?? ""
//     }
//    
//   private func generateRandomQuizName() -> String {
//       let names = ["New Testement", "Old Testement", "Ephesians", "Paul's Messages", "Jesus of Nazareth", "The Trinity", "Apostole Peter"]
//       return names.randomElement() ?? ""
//    }
//    private func generateRandomQuestionNames() -> String {
//        let names = ["How did Jesus die", "What was the name of first Apostle", "What was Jesus's first mircale", "How much time did Moses strangle in the desert", "What does 'Mesiah' mean", "Who was Abraham", "Apostole Peter was not jewish"]
//       return names.randomElement() ?? ""
//    }
//    private func generateRandomAnswerNames() -> String {
//        let names = ["On the cross", "John", "Turning water into wine", "40 years", "The saviour", "God's friend", "False", "True"]
//       return names.randomElement() ?? ""
//    }
//    
//    
//    
//    private func generateRandomDificulty() -> DifficultyLevel {
//        return DifficultyLevel.allCases.randomElement() ?? .newBorn
//    }
//    
//    private func generateRandomCorrect() -> Bool {
//        let isCorrect: Bool = Bool.random()
//        return isCorrect
//    }
//    
//    private func generateRandomQuestions() -> [Question] {
//        var questions: [Question] = []
//        var answers: [Answer] = []
//        for _ in 0..<4 {
//            let answer = Answer(isCorrect: self.generateRandomCorrect(), isSelected: false, text: self.generateRandomAnswerNames())
//            answers.append(answer)
//        }
//        for _ in 0..<4 {
//            let newQuestion = Question(text: self.generateRandomQuestionNames(), explanation: "Nothing", answers: answers)
//            
//            questions.append(newQuestion)
//        }
//        
//        return questions
//    }
//    
//    private func generateRandomTopicStatus() -> TopicStatus {
//        return TopicStatus.allCases.randomElement() ?? .new
//    }
//    
//    private func populateRandomQuiz() {
//        
//        for _ in 0..<10 {
//            let quiz = Quiz(name: self.generateRandomQuizName(), questions: self.generateRandomQuestions(), time: 1234543, status: .new, difficulty: self.generateRandomDificulty(), totalPoints: 150)
//            
//            self.quizes.append(quiz)
//        }
//        
//    }
//    private func populateRandomTopic() {
//        
//        for _ in 0..<5 {
//            let topic = Topic(name: self.generateRandomTopicName(), quizes: self.quizes, status: self.generateRandomTopicStatus())
//            self.topics.append(topic)
//        }
//        
//    }
//}
