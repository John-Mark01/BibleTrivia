//
//  ButtonStyles.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on [Date]
//

import SwiftUI

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    var height: CGFloat = 10
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .applyFont(.medium, size: 16, textColor: .white)
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor(for: configuration))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .sensoryFeedback(.selection, trigger: configuration.isPressed)
    }
    
    private func backgroundColor(for configuration: Configuration) -> Color {
        if configuration.isPressed {
            return Color.BTPrimary.opacity(0.8)
        } else {
            return Color.BTPrimary
        }
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    var height: CGFloat = 10
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .applyFont(.regular, size: 16, textColor: textColor(for: configuration))
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor(for: configuration))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor(for: configuration), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .sensoryFeedback(.selection, trigger: configuration.isPressed)
    }
    
    private func backgroundColor(for configuration: Configuration) -> Color {
        if configuration.isPressed {
            return Color.BTPrimary.opacity(0.1)
        } else {
            return Color.white
        }
    }
    
    private func textColor(for configuration: Configuration) -> Color {
        return Color.BTPrimary
    }
    
    private func borderColor(for configuration: Configuration) -> Color {
        return Color.BTPrimary
    }
}

//MARK: Score Button Style
struct ScoreButton: ButtonStyle {
    var width: CGFloat? = nil
    var height: CGFloat = 70
    var score: String = "0"
    
    func makeBody(configuration: Configuration) -> some View {
        let offset: CGFloat = 6
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.BTSecondary)
                .offset(y: offset)
            
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.BTPrimary)
                .offset(y: configuration.isPressed ? offset : 0)
                
            HStack {
                Image("star")
                    .resizable()
                    .frame(width: 34, height: 34)
                    .foregroundStyle(Color.yellow)
                    .padding(.trailing, 4)
                
                Text("Score:")
                    .applyFont(.semiBold, size: 23, textColor: .white)
                
                Text(score)
                    .applyFont(.semiBold, size: 23, textColor: .white)
            }
            .offset(y: configuration.isPressed ? offset : 0)
        }
        .frame(maxWidth: width ?? .infinity)
        .frame(height: height)
    }
}

//MARK: Streak Button Style
struct StreakButton: ButtonStyle {
    var width: CGFloat? = nil
    var height: CGFloat = 70
    var streak: String = "0"
    
    func makeBody(configuration: Configuration) -> some View {
        let offset: CGFloat = 6
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.BTSecondary)
                .offset(y: offset)
            
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.BTPrimary.gradient)
                .offset(y: configuration.isPressed ? offset : 0)
                
            HStack {
                Image(systemName: "bolt.fill")
                    .resizable()
                    .frame(width: 24, height: 34)
                    .foregroundStyle(Color.BTDarkGray)
                
                Text(streak)
                    .applyFont(.medium, size: 30, textColor: .white)
                    .bold()
            }
            .offset(y: configuration.isPressed ? offset : 0)
        }
        .frame(maxWidth: width ?? .infinity, maxHeight: height)
    }
}

//MARK: Next Button Style
enum ArrowDirection {
    case left, right
}

struct NextButton: ButtonStyle {
    var width: CGFloat? = nil
    var height: CGFloat = 60
    var direction: ArrowDirection = .right
    
    func makeBody(configuration: Configuration) -> some View {
        let offset: CGFloat = 6
        ZStack {
            RoundedRectangle(cornerRadius: 100)
                .foregroundStyle(Color.BTSecondary)
                .offset(y: offset)
            
            RoundedRectangle(cornerRadius: 100)
                .foregroundStyle(Color.BTPrimary)
                .offset(y: configuration.isPressed ? offset : 0)
                
            Image("Arrow")
                .tint(Color.white)
                .rotationEffect(.degrees(direction == .left ? 180 : 0))
                .offset(y: configuration.isPressed ? offset : 0)
        }
        .frame(maxWidth: width ?? .infinity, maxHeight: height)
    }
}

// MARK: - ButtonStyle Extensions
extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
    static func primary(height: CGFloat) -> PrimaryButtonStyle {
        PrimaryButtonStyle(height: height)
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
    static func secondary(height: CGFloat) -> SecondaryButtonStyle {
        SecondaryButtonStyle(height: height)
    }
}

extension ButtonStyle where Self == ScoreButton {
    static var score: ScoreButton { ScoreButton() }
    static func score(width: CGFloat? = nil, height: CGFloat = 70, score: String) -> ScoreButton {
        ScoreButton(width: width, height: height, score: score)
    }
}

extension ButtonStyle where Self == StreakButton {
    static var streak: StreakButton { StreakButton() }
    static func streak(width: CGFloat? = nil, height: CGFloat = 70, streak: String) -> StreakButton {
        StreakButton(width: width, height: height, streak: streak)
    }
}

extension ButtonStyle where Self == NextButton {
    static var next: NextButton { NextButton() }
    static func next(width: CGFloat? = nil, height: CGFloat = 60, direction: ArrowDirection = .right) -> NextButton {
        NextButton(width: width, height: height, direction: direction)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Button("Login") { }
            .buttonStyle(.primary)
        
        Button("Cancel") { }
            .buttonStyle(.secondary)
        
        HStack {
            Button("") { }  // No text needed - UI is built into the style
                .buttonStyle(.score(score: "328"))
            
            Spacer()
            
            Button("") { }  // No text needed - UI is built into the style
                .buttonStyle(.streak(width: 123, streak: "364"))
        }
        
        HStack {
            Button("") { }  // Left arrow
                .buttonStyle(.next(width: 67, direction: .left))
            
            Button("") { }  // Right arrow
                .buttonStyle(.next(width: 67, direction: .right))
        }
    }
    .applyViewPaddings()
    .applyBackground()
}
