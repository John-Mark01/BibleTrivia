//
//  Extensions+String.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 27.09.25.
//

import Foundation

extension String {
    var localized: LocalizedStringResource {
        return LocalizedStringResource(stringLiteral: self)
    }
}
