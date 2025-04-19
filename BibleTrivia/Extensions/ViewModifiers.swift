//
//  ViewModifiers.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 19.04.25.
//

import SwiftUI

//MARK: Background + Padding

struct BTBackground: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.BTBackground)
    }
}
struct BTViewPadding: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, Constants.hPadding)
            .padding(.vertical, Constants.vPadding)
    }
}

struct BTEdgesPadding: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
    }
}
