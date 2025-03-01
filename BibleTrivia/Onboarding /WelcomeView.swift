//
//  WelcomeView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 18.01.25.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(Router.self) private var router
    
    func onRegistration() {
        router.navigateTo(.getEmail)
    }
    func onLogin() {
        router.navigateTo(.login)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            
            Text("Welcome to\nBibleTrivia")
                .modifier(CustomText(size: 45, font: .semiBold))
                .multilineTextAlignment(.center)
            
            
            Text("Learn the Bible the fun way!")
                .modifier(CustomText(size: 20, font: .medium))
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, Constants.hPadding)
        .padding(.vertical, Constants.vPadding)
        .background(Color.BTBackground)
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
    .environment(Router.shared)
}
