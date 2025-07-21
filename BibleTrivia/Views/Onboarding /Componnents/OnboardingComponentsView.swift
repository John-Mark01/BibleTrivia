//
//  OnboardingComponentsView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 18.01.25.
//

import SwiftUI

struct OnboardingComponentsView: View {
    @State private var valueForTextField: String = ""
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {

                OnboardingProcessView(action: {print("Back button taped")})
                
                Spacer()
                
                OnboardButton(text: "Continue", action: {print("Hello there....")})
                
                ProviderLoginButton(provider: .google,
                                    backgroundColor: .white,
                                    shadow: 8,
                                    action: {})
                ProviderLoginButton(provider: .apple,
                                    backgroundColor: .white,
                                    shadow: 8,
                                    action: {})
                
                NewBTTextField(value: $valueForTextField, placeholder: "Email")
                
                AvatarView()
                
                Spacer()
            }
            .padding(.horizontal, Constants.hPadding)
        }
        .frame(maxWidth: .infinity)
        .background(Color.BTBackground)
    }
}

#Preview {
    NavigationStack {
        OnboardingComponentsView()
    }
}
