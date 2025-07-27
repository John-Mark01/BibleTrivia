//
//  GetEmailView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 19.01.25.
//

import SwiftUI

struct GetEmailView: View {
    @Environment(Router.self) private var router
    @Environment(OnboardingManager.self) var onboardingManager
    
    @State private var email: String = ""
    @State private var country: String = ""
    @State private var searchQuery: String = ""
    
    func onContinue() {
        onboardingManager.loadSurvey()
        router.navigateTo(.surveyView, from: .onboarding)
    }
    func getCountries() {
        
    }
    func onCountrySelection() {
        
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            CustomNavigationBar(title: "Enter your details",
                                leftButtonAction: {
                print("Navigate back")
                router.popBackStack()
            })
            
            
            VStack(alignment: .leading) {
                Text("Enter your email")
                    .applyFont(.medium, size: 20)
                
                NewBTTextField(value: $email, placeholder: "Email")
            }
            .padding(.top, 30)
            
            //TODO: Countries need to be get from the OnboardingManager
            //TODO: Countries need to be extracted in a subview
            
            
            OnboardCountriesListView(onCountrySelection: onCountrySelection, getCountries: getCountries)
                .padding(.top, 20)
            
            
            OnboardButton(text: "Continue", action: onContinue)
            
        }
        .navigationBarBackButtonHidden()
        .padding(.top, 30)
        .applyViewPaddings(.horizontal)
        .dismissKeyboardOnTap()
        .applyBackground()
    }
}

#Preview {
    RouterView {
        GetEmailView()
    }
    .environment(OnboardingManager(supabase: Supabase()))
    .environment(Router.shared)
}

struct OnboardCountriesListView: View {
    
    let onCountrySelection: () -> Void
    let getCountries: () -> Void
    @State private var searchQuery: String = ""
    
//    var countries: [Country] = []
    var body: some View {
        VStack(alignment: .leading) {
            Text("Select your country")
                .applyFont(.medium, size: 20)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(0..<10) { index in
                        
                        Button(action: {
                            onCountrySelection()
                        }) {
                            HStack(spacing: 10) {
                                Image("BG_Flag")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                
                                Text("Bulgaria")
                                    .applyFont(.medium, size: 17)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.BTLightGray)
                            .clipShape(.rect(cornerRadius: 12))
                        }
                        
                    }
                }
            }
            .refreshable {
                getCountries()
            }
        }
    }
}
