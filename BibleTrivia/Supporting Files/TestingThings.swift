//
//  TestingThings.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 28.02.25.
//

import SwiftUI

struct TestingThings: View {
    var body: some View {
        
        VStack {
            HStack {
                Text("Hello There")
                    .applyFont(style: .medium, size: 40)
                
                Spacer()
                
                Image(systemName: "house")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .addInsideaddings()
            .border(.blueGradient)
            
            Spacer()
        }
        .addViewPaddings()
        .addBackground()
    }
}

#Preview {
    TestingThings()
}
