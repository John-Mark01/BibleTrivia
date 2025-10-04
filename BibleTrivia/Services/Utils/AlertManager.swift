//
//  AlertManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 19.01.25.
//

import Foundation

@Observable class AlertManager {
    
    private init() {}
    static let shared = AlertManager()
    
    var show: Bool = false
    
    var alertTitle: LocalizedStringResource = "Error"
    var alertMessage: LocalizedStringResource = "Something went wrong. Please try again later."
    var buttonText: LocalizedStringResource = "Dismiss"
    var action: () -> Void = {}
    
    
    func showAlert(type: AlertType,
                   title: LocalizedStringResource? = nil,
                   message: LocalizedStringResource,
                   buttonText: LocalizedStringResource,
                   action: @escaping () -> Void) {
        
       switch type {
        case .error:
           self.alertTitle = type.rawValue
        case .warning:
           self.alertTitle = type.rawValue
        case .success:
           self.alertTitle = type.rawValue
        case .information:
           self.alertTitle = type.rawValue
        }
        
        if let title = title {
            self.alertTitle = title
        }
        
        self.alertMessage = message
        self.buttonText = buttonText
        self.action = action
        self.show = true
    }
    
//MARK: View Specific alerts
    
    //QuizView
    func showQuizExitAlert(quizName: String, action: @escaping () -> Void) {
        self.showAlert(type: .warning,
                       title: "Quit Quiz?",
                       message: "Do want to quit \(quizName)?\nYou can still finish your quiz later.",
                       buttonText: "Close Quiz",
                       action: action)
    }
    
    //BTError
    func showBTErrorAlert(_ error: Errors.BTError, buttonTitle: LocalizedStringResource, action: @escaping () -> Void) {
        var alertMessage: LocalizedStringResource = ""
        switch error {
        case let .networkError(message):
            alertMessage = message
        case let .invalidResponse(message):
            alertMessage = message
        case let .parseError(message):
            alertMessage = message
        case let .signUpError(message):
            alertMessage = message
        case let .logInError(message):
            alertMessage = message
        case let .forgotPasswordError(message):
            alertMessage = message
        case let .unknownError(message):
            alertMessage = message
        }
        
        self.showAlert(type: .error, message: alertMessage, buttonText: buttonTitle, action: action)
    }
    
    //Feature comming sooom
    func showFeatureCommingSoonAlert(for feature: String, action: @escaping () -> Void = {}) {
        let alertMessage = LocalizedStringResource(stringLiteral: "\(feature)" + " is comming soon. Stay tuned!")
        self.showAlert(type: .information, message: alertMessage, buttonText: "Close", action: action)
    }

}

enum AlertType: LocalizedStringResource {
    case error = "Error"
    case warning = "Warning"
    case success = "Success"
    case information = "Information"
}

enum AlertActionType {
    case oneAction(action: () -> Void)
    case twoActions(action1: () -> Void, action2: () -> Void)
}
