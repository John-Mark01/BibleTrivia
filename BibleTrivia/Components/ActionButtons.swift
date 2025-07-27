//
//  CustomButton.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 13.10.24.
//

import SwiftUI

struct ActionButtons: View {
    let title: String
    let action: () -> Void
    let isPrimary: Bool
    var height: CGFloat = 0
    var disabled: Bool = false
    
    init(title: String, isPrimary: Bool = true, height: CGFloat = 10, disabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isPrimary = isPrimary
        self.action = action
        self.height = height
        self.disabled = disabled
    }
    
    private var fillColor: Color {
        if isPrimary {
            Color.BTPrimary.opacity(disabled ? 0.5 : 1)
        } else {
            Color.white.opacity(disabled ? 0.5 : 1)
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isPrimary ? .white : .green)
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(fillColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.BTPrimary, lineWidth: isPrimary ? 0 : 1)
                )
        }
        .disabled(disabled)
    }
}

#Preview {
    VStack {
        ActionButtons(title: "Login", isPrimary: true, disabled: false, action: {})
        ActionButtons(title: "Register", isPrimary: false, disabled: false, action: {})
    }
    .applyViewPaddings()
}
