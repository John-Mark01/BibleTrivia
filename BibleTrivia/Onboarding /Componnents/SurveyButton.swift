//
//  SurveyButton.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 5.02.25.
//

import SwiftUI

struct SurveyButton: View {
    @State private var isSelected: Bool = false
    let text: String
    var colorUnselected: Color
    var colorSelected: Color
    let actionOnSelect: (() -> Void)
    let actionOnUnSelect: (() -> Void)
    var disabled: Bool = false
    @Binding var resetSelection: Bool
    
    init(text: String, colorUnselected: Color = .BTStroke, colorSelected: Color = .BTPrimary, actionOnSelect: @escaping () -> Void, actionOnUnSelect: @escaping () -> Void, disabled: Bool = false, resetSelection: Binding<Bool>) {
        self.text = text
        self.colorUnselected = colorUnselected
        self.colorSelected = colorSelected
        self.actionOnSelect = actionOnSelect
        self.actionOnUnSelect = actionOnUnSelect
        self.disabled = disabled
        self._resetSelection = resetSelection
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
                withAnimation(.linear(duration: 0.25)) {
                    if !disabled {
                        isSelected.toggle()
                        if isSelected {
                            actionOnSelect()
                        } else {
                            actionOnUnSelect()
                        }
                    } else {
                        if isSelected {
                            isSelected.toggle()
                            actionOnUnSelect()
                        }
                    }
                }
            }
            .onChange(of: resetSelection) { _, newValue in
                if newValue {
                    isSelected = false
                }
            }
            
    }
}
