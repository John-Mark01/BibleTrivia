//
//  ThreeDButton.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 15.10.24.
//

import SwiftUI

struct ScoreButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let offset: CGFloat = 6
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.BTSecondary)
                .offset(y: offset)
            
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.BTPrimary)
                .offset(y: configuration.isPressed ? offset : 0)
                
            configuration.label
                .offset(y: configuration.isPressed ? offset : 0)
        }
        
    }
}

struct StreakButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let offset: CGFloat = 6
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.BTSecondary)
                .offset(y: offset)
            
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.BTPrimary.gradient)
                .offset(y: configuration.isPressed ? offset : 0)
                
            configuration.label
                .offset(y: configuration.isPressed ? offset : 0)
        }
        
    }
}
struct NextButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let offset: CGFloat = 6
        ZStack {
            RoundedRectangle(cornerRadius: 100)
                .foregroundStyle(Color.BTSecondary)
                .offset(y: offset)
            
            RoundedRectangle(cornerRadius: 100)
                .foregroundStyle(Color.BTPrimary)
                .offset(y: configuration.isPressed ? offset : 0)
                
            configuration.label
                .offset(y: configuration.isPressed ? offset : 0)
        }
        
    }
}

struct ThreeDButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Button") {
            
        }
        .foregroundStyle(Color.BTBackground)
        .frame(width: 150, height: 50)
        .buttonStyle(ScoreButton())
    }
}
