//
//  LoginViewModel.swift
//  BibleTrivia
//

import Foundation

@Observable
final class LoginViewModel {
    var email = ""
    var password = ""

    /// Only flag the email once it looks complete enough to judge.
    var showEmailError: Bool {
        email.count > 5 && !Validation.isValid(email: email)
    }

    var canSubmit: Bool {
        Validation.isValid(email: email) && !password.isEmpty
    }

    var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
