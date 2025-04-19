//
//  Extensions+View.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 19.04.25.
//

import SwiftUI

extension View {
    
//MARK: Background + Padding
    
    func addBackground() -> some View {
        self.modifier(BTBackground())
    }
    
    func addViewPaddings() -> some View {
        self.modifier(BTViewPadding())
    }
    
    func addInsideaddings() -> some View {
        self.modifier(BTEdgesPadding())
    }
    
//MARK: Keyboard dismissal
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
