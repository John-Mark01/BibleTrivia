//
//  WelcomeView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 18.01.25.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(Router.self) private var router
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            
            Text("Welcome to\nBibleTrivia")
                .applyFont(.semiBold, size: 45)
                .multilineTextAlignment(.center)
            
            
            Text("Learn the Bible the fun way!")
                .applyFont(.medium, size: 20)
                .padding()
            
            //TODO: Need to add something in the middle
            //TODO: Maybe an animation, or value pageview
            
            Spacer()
            
            OnboardButton(text: "Get started",
                          action: onRegistration)
            
            OnboardButton(text: "I already have an account",
                          textColor: .black,
                          backgroundColor: .white,
                          strokeColor: .black,
                          action: onLogin)
            
        }
        .applyViewPaddings()
        .applyBackground()
    }
    
    private func onRegistration() {
        router.navigateTo(.registration)
    }
    
    private func onLogin() {
        router.navigateTo(.login)
    }
}

#Preview {
    PreviewEnvironmentView {
        WelcomeView()
    }
}
