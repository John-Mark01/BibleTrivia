//
//  RegistrationViewModel.swift
//  BibleTrivia
//

import Foundation

@Observable
final class RegistrationViewModel {
    var firstName = ""
    var lastName = ""
    var age = ""
    var email = ""
    var password = ""

    // Errors appear only once a field has content, so the empty form isn't all red.
    var firstNameError: LocalizedStringResource? {
        firstName.isEmpty || Validation.isValid(name: firstName) ? nil : "Please enter your first name"
    }

    var lastNameError: LocalizedStringResource? {
        lastName.isEmpty || Validation.isValid(name: lastName) ? nil : "Please enter your last name"
    }

    var ageError: LocalizedStringResource? {
        age.isEmpty || Validation.isValid(age: age) ? nil : "You must be at least \(Validation.minimumAge) years old"
    }

    var emailError: LocalizedStringResource? {
        email.count <= 5 || Validation.isValid(email: trimmedEmail) ? nil : "Invalid email"
    }

    var passwordError: LocalizedStringResource? {
        password.isEmpty || Validation.isValid(password: password)
            ? nil
            : "At least 8 characters, with an uppercase letter, a lowercase letter and a number"
    }

    var canSubmit: Bool {
        Validation.isValid(name: firstName)
            && Validation.isValid(name: lastName)
            && Validation.isValid(age: age)
            && Validation.isValid(email: trimmedEmail)
            && Validation.isValid(password: password)
    }

    var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
