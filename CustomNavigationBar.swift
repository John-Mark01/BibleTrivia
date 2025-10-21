//
//  CustomNavigationBar.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 18.01.25.
//


import SwiftUI


struct CustomNavigationBar: View {
    let title: String
    var leftButtonAction: (() -> Void)?
    var rightButtonAction: (() -> Void)?
    var leftButtonIcon: String = "Arrow"
    var leftButtonDirection: LayoutDirection = .leftToRight
    var rightButtonIcon: String?
    var backgroundColor: Color = .BTBackground
    
    var body: some View {
        HStack(spacing: 16) {
            // Left Button (usually back button)
            if let leftAction = leftButtonAction {
                Button(action: leftAction) {
                    Image(leftButtonIcon)
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .layoutDirectionBehavior(.mirrors(in: leftButtonDirection))
                }
            } else {
                Spacer()
            }
            
            Spacer()
            
            // Title
            Text(title)
                .applyFont(.medium, size: 20)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            // Right Button (optional)
            if let rightAction = rightButtonAction, let rightIcon = rightButtonIcon {
                Button(action: rightAction) {
                    Image(systemName: rightIcon)
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                        .frame(width: 44, height: 44)
                }
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .dismissKeyboardOnTap()
    }
}
