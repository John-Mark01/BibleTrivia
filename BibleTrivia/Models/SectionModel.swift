//
//  SectionModel.swift
//  BibleTrivia
//

import SwiftUI

/// A row in a settings-style form (`BTForm`).
struct SectionModel {
    let name: LocalizedStringKey
    let image: String
    let action: () -> Void
}
