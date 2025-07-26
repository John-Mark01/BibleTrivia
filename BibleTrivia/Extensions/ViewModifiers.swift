//
//  ViewModifiers.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 19.04.25.
//

import SwiftUI

//MARK: Background
struct BTBackground: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.BTBackground)
    }
}

//MARK: Paddings
struct BTViewPadding: ViewModifier {
    
    var choise: PaddingChoise
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, choise != .vertical ? Constants.horizontalPadding : 0)
            .padding(.vertical, choise != .horizontal ? Constants.verticalPadding : 0)
    }
    
    enum PaddingChoise {
        case horizontal
        case vertical
        case all
    }
}

struct BTEdgesPadding: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(Constants.edgeInsets)
    }
}

//MARK: Buttons
struct BTButtonRenderer: ViewModifier {
    
    var action: () -> Void
    var hapticsEnabled: Bool
    var hapticFeedbackStyle: SensoryFeedback
    
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        Button(action: {
            isPressed.toggle()
            action()
        }) {
            content
        }
        .sensoryFeedback(hapticFeedbackStyle, trigger: hapticsEnabled ? isPressed : false)
    }
}

//MARK: Navigation & Toolbar
struct BTAccountToolbarItem: ViewModifier {
    
    var placement: ToolbarItemPlacement
    var image: Image
    var onTap: () -> Void
    
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        
        content
            .toolbar {
                ToolbarItem(placement: placement) {
                    Button(action: {
                        isPressed.toggle()
                        onTap()
                    }) {
                        image
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(
                                Circle()
                            )
                            .background(
                                Circle()
                                    .frame(width: 36, height: 36)
                            )
                    }
                    .sensoryFeedback(.impact, trigger: isPressed)
                }
            }
    }
}

//MARK: Text & Font
struct CustomText: ViewModifier {
    
    var size: CGFloat
    var font: FontStyle
    var foregroundColor: Color
    
    func getFont(from style: FontStyle) -> Font {
        switch style {
        case .semiBold:
            Font.custom("Rubik-SemiBold", size: size)
        case .medium:
            Font.custom("Rubik-Medium", size: size)
        case .regular:
            Font.custom("Rubik-Regular", size: size)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .font(getFont(from: font))
            .foregroundStyle(foregroundColor)
    }
    
    enum FontStyle {
        case semiBold
        case medium
        case regular
    }
}
