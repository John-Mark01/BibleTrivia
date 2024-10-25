//
//  CustomText.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 10.10.24.
//

import SwiftUI

struct CustomText: ViewModifier {

    var size: CGFloat
    var font: FontStyle
    
    enum FontStyle {
        case semiBold
        case medium
        case regular
    }
    
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
    }
}

