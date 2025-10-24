//
//  BTContentBox.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 13.10.25.
//

import SwiftUI

struct BTContentBox<Content: View>: View {
    var background: Color = .white
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.boxStroke, lineWidth: 2)
                .fill(background)
                .foregroundStyle(.white)
            
            content()
                .padding(Constants.horizontalPadding)
        }
    }
}

#Preview {
    VStack {
        BTContentBox {
            HStack {
                Text("Hello")
                Image(systemName: "house")
                    .font(.largeTitle)
            }
        }
        
        Spacer()
    }
    .applyViewPaddings()
    .applyBackground()
}
