//
//  ProviderLoginButton.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 18.01.25.
//

import SwiftUI

struct ProviderLoginButton: View {
    var provider: Provider = .apple
    let textColor: Color
    let backgroundColor: Color
    let cornerSize: CGFloat
    let strokeColor: Color
    let strokeSize: CGFloat
    let shadow: CGFloat
    let action: () -> Void
    
    private var providerImage: String {
        switch provider {
        case .apple:
            "AppleIcon"
        case .google:
            "GoogleIcon"
        }
    }
    @State private var isTapped: Bool = false
    
    init(provider: Provider, textColor: Color = .black, backgroundColor: Color = .white, cornerSize: CGFloat = 20, strokeColor: Color = .black, strokeSize: CGFloat = 0, shadow: CGFloat = 0, action: @escaping () -> Void) {
        self.provider = provider
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.cornerSize = cornerSize
        self.strokeColor = strokeColor
        self.strokeSize = strokeSize
        self.shadow = shadow
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            isTapped.toggle()
            action()
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image(providerImage)
                    .resizable()
                    .frame(width: 20, height: 23)
                
                Text("Sign in with \(provider.rawValue)")
                    .modifier(CustomText(size: 19, font: .regular))
                    .foregroundStyle(textColor)
                    
            }
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(backgroundColor)
            .clipShape(.rect(cornerRadius: cornerSize))
            .overlay(
                RoundedRectangle(cornerRadius: cornerSize)
                    .stroke(strokeColor, lineWidth: strokeSize)
            )
            .shadow(radius: shadow)
        }
        .sensoryFeedback(.selection, trigger: isTapped)
    }
}

#Preview {
    ProviderLoginButton(provider: .google,
                        backgroundColor: .white,
                        shadow: 8,
                        action: {})
    .padding(.horizontal, 16)
}
