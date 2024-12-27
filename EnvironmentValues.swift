//
//  EnvironmentValues.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 3.12.24.
//

import SwiftUI

struct UserNameValue: EnvironmentKey {
    static let defaultValue: String = "User"
}

extension EnvironmentValues {
    var userName: String {
        get {
            self[UserNameValue.self]
        }
        set {
            self[UserNameValue.self] = newValue
        }
        
    }
}
