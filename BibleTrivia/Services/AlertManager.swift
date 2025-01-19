//
//  AlertManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 19.01.25.
//

import Foundation

@Observable class AlertManager {
    
    static let shared = AlertManager()
    
    var show: Bool = false
    
    var alertTitle: String = "Error"
    var alertMessage: String = "Something went wrong. Please try again later."
    var buttonText: String = "Dismiss"
    
    var primaryAction: (() -> Void)?
    var secondaryAction: (() -> Void)?
    
    
    func showAlert(type: AlertType, title: String? = nil, message: String, buttonText: String) {
        
        if let title = title {
            self.alertTitle = title
        }
        
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
        self.alertMessage = message
        self.buttonText = buttonText
        self.show = true
    }
    
    func showDefaultAlert( message: String, buttonText: String = "Dismiss") {
       
        self.alertTitle = AlertType.warning.rawValue
        self.alertMessage = message
        self.buttonText = buttonText
        self.show = true
    }
    
    //TODO: Alert with two buttons
    func showActionAlert(_ action: AlertActionType) {}
    
    enum AlertType: String {
        case error = "Error"
        case warning = "Warning"
        case success = "Success"
        case information = "Information"
    }
    
    enum AlertActionType {
        case defaulT
        case oneAction
        case twoActions
        case textField
        case review
    }
}
