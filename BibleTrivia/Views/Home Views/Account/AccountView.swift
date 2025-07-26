//
//  AccountView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.11.24.
//

import SwiftUI

struct AccountView: View {
    @Environment(UserManager.self) var userManager
    
    @State private var generalSection: [SectionModel] = [
        SectionModel(name: "My Progress", image: "progress"),
        SectionModel(name: "Friends", image: "friends")
    ]
    
    @State private var moreSection: [SectionModel] = [
        SectionModel(name: "Account Information", image: "Account"),
        SectionModel(name: "Notifications", image: "notifications"),
        SectionModel(name: "Settings", image: "settings"),
        SectionModel(name: "Logout", image: "logout")
    ]
    var body: some View {
        
        ScrollView {
            UserAccountCard(user: userManager.user)
                .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 16) {
                BTForm(section: generalSection, sectionName: "General", action: {})
                BTForm(section: moreSection, sectionName: "More", action: {
                    Task {
                        await userManager.signOut()
                    }
                })
            }
        }
        .background(Color.BTBackground)
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.vertical, Constants.verticalPadding)
        .navigationTitle("Account")
    }
}

#Preview {
    NavigationView {
        AccountView()
    }
}

struct BTForm: View {
    var section: [SectionModel]
    var sectionName: String
    var action: () -> Void
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(sectionName)
                .applyFont(.semiBold, size: 20)
            
            VStack {
                VStack(spacing: 20) {
                    ForEach(section.indices, id: \.self) { index in
                        BTFormButton(buttonName: section[index].name, imageName: section[index].image, action: action)
                        if index < section.count - 1 {
                            Divider()
                        }
                       
                    }
                }
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                          RoundedRectangle(cornerRadius: 20)
                              .stroke(Color.BTStroke,lineWidth: 1)
                      )
                
                
            }
            .background(Color.clear)
            .tint(Color.BTBlack)
        }
    }
}




struct BTFormButton: View {
    var buttonName: String
    var imageName: String
    var action: () -> Void
    
    var body: some View {
        
        Button(action: {
            withAnimation {
                action()
            }
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image(imageName)
                
                Text(buttonName)
                    .applyFont(.regular, size: 16)
                
                Spacer()
                
                Image("Go_Arrow")
                    .tint(Color.black)
            }
        }
    }
}

