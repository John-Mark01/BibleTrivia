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
        case title
        case h1
        case heading
        case questionTitle
        case body
        case label
        case button
    }
    
    func getFont(from style: FontStyle) -> Font {
        switch style {
        case .title:
            Font.custom("Rubik-Medium", size: size)
        case .h1:
            Font.custom("Rubik-Medium", size: size)
        case .heading:
            Font.custom("Rubik-SemiBold", size: size)
        case .questionTitle:
            Font.custom("Rubik-SemiBold", size: size)
        case .body:
            Font.custom("Rubik-Regular", size: size)
        case .label:
            Font.custom("Rubik-Regular", size: size)
        case .button:
            Font.custom("Rubik-Medium", size: size)
        }
    }
    func body(content: Content) -> some View {
        content
            .font(getFont(from: font))
    }
}

