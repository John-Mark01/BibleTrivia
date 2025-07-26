//
//  ActionButtons.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 18.01.25.
//

import SwiftUI

struct OnboardButton: View {
    let text: String
    let textColor: Color
    let textSize: CGFloat
    let backgroundColor: Color
    let strokeColor: Color
    let strokeSize: CGFloat
    var disabled: Bool
    let action: () -> Void
    @State private var isTapped = false
    
    init(text: String, textColor: Color = .white, textSize: CGFloat = 20, backgroundColor: Color = .BTPrimary, strokeColor: Color = .BTPrimary, strokeSize: CGFloat = 1, disabled: Bool = false, action: @escaping () -> Void) {
        self.text = text
        self.textColor = textColor
        self.textSize = textSize
        self.backgroundColor = backgroundColor
        self.strokeColor = strokeColor
        self.strokeSize = strokeSize
        self.action = action
        self.disabled = disabled
    }
    
    var body: some View {
        Button(action: {
            isTapped.toggle()
            action()
        }) {
            Text(text)
                .applyFont(.medium, size: textSize, textColor: textColor)
                .frame(maxWidth: .infinity)
                .lineLimit(1)
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(backgroundColor.opacity(disabled ? 0.5 : 1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(strokeColor, lineWidth: strokeSize)
                )
        }
        .sensoryFeedback(.impact(flexibility: .solid, intensity: 100), trigger: isTapped)
        .disabled(disabled)
    }
}

#Preview {
    OnboardButton(text: "Let's Go",
                  textColor: .black,
                  backgroundColor: .white,
                  strokeColor: .black,
                  strokeSize: 0.7,
                  disabled: false,
                  action: {print("Onboard button clicked")})
        .padding(.all, 20)
}
