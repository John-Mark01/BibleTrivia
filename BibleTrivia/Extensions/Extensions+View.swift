//
//  Extensions+View.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 19.04.25.
//

import SwiftUI

extension View {
    
//MARK: Background
    func applyBackground() -> some View {
        self.modifier(BTBackground())
    }
    
//MARK: Paddings
    func applyViewPaddings(_ choise: BTViewPadding.PaddingChoise = .all) -> some View {
        self.modifier(BTViewPadding(choise: choise))
    }
    
    func applyInsideViewPaddings() -> some View {
        self.modifier(BTEdgesPadding())
    }
    
//MARK: Buttons
    func makeButton(action: @escaping () -> Void,
                    addHapticFeedback: Bool = false,
                    feedbackStyle: SensoryFeedback = .impact) -> some View {
        self.modifier(BTButtonRenderer(action: action, hapticsEnabled: addHapticFeedback, hapticFeedbackStyle: feedbackStyle))
    }
    
//MARK: Keyboard dismissal
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
//MARK: Text & Font
    func applyFont(_ style: CustomText.FontStyle, size: CGFloat, textColor: Color = .BTBlack) -> some View {
        self.modifier(CustomText(size: size, font: style, foregroundColor: textColor))
    }
    
    
//MARK: Navigation & Toolbar
    func applyAccountButton(placement: ToolbarItemPlacement = .topBarLeading, avatar: Image, onTap: @escaping () -> Void) -> some View {
        self.modifier(BTAccountToolbarItem(placement: placement, image: avatar, onTap: onTap))
    }
}
