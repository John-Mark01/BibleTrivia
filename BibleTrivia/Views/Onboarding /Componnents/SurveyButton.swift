//
//  SurveyButton.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 5.02.25.
//

import SwiftUI

struct SurveyButton: View {
    let text: String
    let isSelected: Bool
    let colorUnselected: Color
    let colorSelected: Color
    let action: () -> Void
    let disabled: Bool
    
    init(
        text: String,
        isSelected: Bool,
        colorUnselected: Color = .gray,
        colorSelected: Color = .green,
        action: @escaping () -> Void,
        disabled: Bool = false
    ) {
        self.text = text
        self.isSelected = isSelected
        self.colorUnselected = colorUnselected
        self.colorSelected = colorSelected
        self.action = action
        self.disabled = disabled
    }
    
    var body: some View {
        
        RoundedRectangle(cornerRadius: 14)
            .stroke(isSelected ? colorSelected : colorUnselected, lineWidth: 4)
            .frame(height: 50)
            .overlay {
                HStack {
                    Text(text)
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    Spacer()
                }
            }
            .onTapGesture {
//                if !disabled {
                    withAnimation(.linear(duration: 0.25)) {
                        action()
                    }
//                }
            }
            .opacity(disabled && !isSelected ? 0.6 : 1.0)
    }
}
