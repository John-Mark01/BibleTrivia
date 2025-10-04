//
//  LoginViewModel.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 4.10.25.
//

import Foundation


@Observable
class LoginViewModel {
    var email = ""
    var password = ""
    
    var showEmailError: Bool = false
    var showPasswordError: Bool = false
    
    var loginDisabled: Bool {
        email.isEmpty || password.isEmpty
    }
        
    func validateEmail() {
        if !email.isEmpty && email.count > 5 {
            if Validations.isValid(email: email) == false {
                showEmailError = true
            } else {
                showEmailError = false
            }
        } else {
            showEmailError = false
        }
    }
    
    func validatePassword() {
        if !password.isEmpty && password.count > 5 {
            if Validations.isValidPassword(password: password) == false {
                showPasswordError = true
            } else {
                showPasswordError = false
            }
        } else {
            showPasswordError = false
        }
    }
}
