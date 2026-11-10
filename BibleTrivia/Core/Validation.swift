//
//  Validation.swift
//  BibleTrivia
//

import Foundation

enum Validation {
    static let minimumAge = 14

    static func isValid(email: String) -> Bool {
        email.wholeMatch(of: #/[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}/#) != nil
    }

    /// Letters (any script), spaces, apostrophes and hyphens; at least 2 characters.
    static func isValid(name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return trimmed.count >= 2 && trimmed.wholeMatch(of: #/[\p{L}' -]+/#) != nil
    }

    /// At least 8 characters with an uppercase letter, a lowercase letter and a digit.
    static func isValid(password: String) -> Bool {
        password.count >= 8
            && password.contains(where: \.isUppercase)
            && password.contains(where: \.isLowercase)
            && password.contains(where: \.isNumber)
    }

    static func isValid(age: String) -> Bool {
        guard let value = Int(age) else { return false }
        return (minimumAge...120).contains(value)
    }
}
