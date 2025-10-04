//
//  RegistrationViewModel.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 4.10.25.
//

import Foundation

@Observable
class RegistrationViewModel {
    var firstName = ""
    var lastName = ""
    var age = ""
    var email = ""
    var password = ""
    
    var showFirstNameError: Bool = false
    var showLastNameError: Bool = false
    var showAgeError: Bool = false
    var showEmailError: Bool = false
    var showPasswordError: Bool = false
    
    var registerDisabled: Bool {
        showFirstNameError ||
        showLastNameError ||
        showAgeError ||
        showEmailError ||
        showPasswordError ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        age.isEmpty ||
        email.isEmpty ||
        password.isEmpty
    }
        
    func validateFirstName() {
        if !firstName.isEmpty && firstName.count > 5 {
            if Validations.isValid(name: firstName) == false {
                showFirstNameError = true
            } else {
                showFirstNameError = false
            }
        } else {
            showFirstNameError = false
        }
    }
        
    func validateLastName() {
        if !lastName.isEmpty && lastName.count > 5 {
            if Validations.isValid(name: lastName) == false {
                showLastNameError = true
            } else {
                showLastNameError = false
            }
        } else {
            showLastNameError = false
        }
    }
   
        
    func validateAge() {
        if !age.isEmpty && age.count > 0 {
            if Int(age) ?? 0 < 14 { //minimum user age == 14 years old
                showAgeError = true
            } else {
                showAgeError = false
            }
        } else {
            showAgeError = false
        }
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
