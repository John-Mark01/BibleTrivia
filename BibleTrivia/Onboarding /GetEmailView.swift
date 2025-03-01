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
        router.navigateTo(.surveyView)
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
                    .modifier(CustomText(size: 20, font: .medium))
                
                NewBTTextField(value: $email, placeholder: "Email")
            }
            .padding(.top, 30)
            
            //TODO: Countries need to be get from the OnboardingManager
            //TODO: Countries need to be extracted in a subview
            
            
            OnboardCountriesListView(onCountrySelection: onCountrySelection, getCountries: getCountries)
                .padding(.top, 20)
            
            
            Spacer()
            
            OnboardButton(text: "Continue", action: onContinue)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard)
        .padding(.horizontal, Constants.hPadding)
        .padding(.vertical, 30)
        .background(Color.BTBackground)
        .onTapGesture {
            dismissKeyboard()
        }
    }
}

#Preview {
    NavigationStack {
        GetEmailView()
            .environment(OnboardingManager())
            .environment(Router.shared)
    }
}

struct OnboardCountriesListView: View {
    
    let onCountrySelection: () -> Void
    let getCountries: () -> Void
    @State private var searchQuery: String = ""
    
//    var countries: [Country] = []
    var body: some View {
        VStack(alignment: .leading) {
            Text("Select your country")
                .modifier(CustomText(size: 20, font: .medium))
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
                                    .modifier(CustomText(size: 17, font: .medium))
                                    .foregroundColor(.BTBlack)
                                
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
