//
//  RegistrationView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 3.10.25.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(Router.self) private var router
    @State private var viewModel = RegistrationViewModel()
    
    @FocusState private var firstNameIsFocused: Bool
    @FocusState private var lastNameIsFocused: Bool
    @FocusState private var ageIsFocused: Bool
    @FocusState private var emailIsFocused: Bool
    @FocusState private var passwordIsFocused: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: Constants.vStackSpacing) {
            
            //Navigation Bar
            CustomNavigationBar(
                title: "Welcome to BibleTrivia!",
                leftButtonAction: { router.popBackStack() }
            )
            .padding(.bottom, 16)

            
            Group {
                //FirstName
                VStack(alignment: .leading, spacing: Constants.vStackSpacing / 2) {
                    NewBTTextField(
                        value: $viewModel.firstName,
                        isFocused: _firstNameIsFocused,
                        placeholder: "first name",
                        keyboardType: .default,
                        contentType: .givenName
                    )
                    
                    if viewModel.showFirstNameError {
                        Text("Invalid First Name")
                            .applyFont(.regular, size: 15, textColor: .red)
                            .animation(.bouncy, value: viewModel.showFirstNameError)
                    }
                }
                .onChange(of: viewModel.firstName) { _, _ in
                    withAnimation {
                        viewModel.validateFirstName()
                    }
                }
                
                //LastName
                VStack(alignment: .leading, spacing: Constants.vStackSpacing / 2) {
                    NewBTTextField(
                        value: $viewModel.lastName,
                        isFocused: _lastNameIsFocused,
                        placeholder: "last name",
                        keyboardType: .default,
                        contentType: .familyName
                    )
                    
                    if viewModel.showLastNameError {
                        Text("Invalid Last Name")
                            .applyFont(.regular, size: 15, textColor: .red)
                            .animation(.bouncy, value: viewModel.showLastNameError)
                    }
                }
                .onChange(of: viewModel.lastName) { _, _ in
                    withAnimation {
                        viewModel.validateLastName()
                    }
                }
                
                //Age
                VStack(alignment: .leading, spacing: Constants.vStackSpacing / 2) {
                    NewBTTextField(
                        value: $viewModel.age,
                        isFocused: _ageIsFocused,
                        placeholder: "age",
                        keyboardType: .numberPad,
                        contentType: .birthdate
                    )
                    
                    if viewModel.showAgeError {
                        Text("You must be at least 14 years old")
                            .applyFont(.regular, size: 15, textColor: .red)
                            .animation(.bouncy, value: viewModel.showAgeError)
                    }
                }
                .onChange(of: viewModel.age) { _, _ in
                    withAnimation {
                        viewModel.validateAge()
                    }
                }
                
                //Email
                VStack(alignment: .leading, spacing: Constants.vStackSpacing / 2) {
                    NewBTTextField(
                        value: $viewModel.email,
                        isFocused: _emailIsFocused,
                        placeholder: "email",
                        keyboardType: .emailAddress,
                        contentType: .emailAddress
                    )
                    
                    if viewModel.showEmailError {
                        Text("Invalid email")
                            .applyFont(.regular, size: 15, textColor: .red)
                            .animation(.bouncy, value: viewModel.showEmailError)
                    }
                }
                .onChange(of: viewModel.email) { _, _ in
                    withAnimation {
                        viewModel.validateEmail()
                    }
                }
                
                //Pssowrd
                VStack(alignment: .leading, spacing: Constants.vStackSpacing / 2) {
                    NewBTSecureField(
                        value: $viewModel.password,
                        isFocused: _passwordIsFocused,
                        placeholder: "password"
                    )
                    
                    if viewModel.showPasswordError {
                        Text("Invalid password")
                            .applyFont(.regular, size: 15, textColor: .red)
                            .animation(.bouncy, value: viewModel.showEmailError)
                    }
                }
                .onChange(of: viewModel.password) { _, _ in
                    withAnimation {
                        viewModel.validatePassword()
                    }
                    
                }
            }
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            
            Button("Sign Up") {
                Task {
                    await authManager.signUpWithEmailConfirmation(
                        email: viewModel.email,
                        password: viewModel.password,
                        firstName: viewModel.firstName,
                        lastName: viewModel.lastName,
                        age: viewModel.age
                    ) {
                        // Navigate to email verification pending view
                        router.navigateTo(.emailVerificationPending(email: viewModel.email))
                    }
                }
            }
            .padding(.top, Constants.vStackSpacing)
            .buttonStyle(.primary)
            .buttonDisabled(viewModel.registerDisabled)
            
            Button("Already have an account? Sign In") {
                router.popToRoot()
                router.navigateTo(.login)
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard)
        .applyViewPaddings(.all)
        .dismissKeyboardOnTap()
        .applyBackground()
    }
}

#Preview {
    PreviewEnvironmentView {
        RegistrationView()
    }
}
