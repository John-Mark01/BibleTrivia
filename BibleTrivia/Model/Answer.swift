//
//  Answer.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 13.10.24.
//

import Foundation

struct Answer {
    let id = UUID()
    var isCorrect: Bool
    var isSelected: Bool
    let text: String
}
