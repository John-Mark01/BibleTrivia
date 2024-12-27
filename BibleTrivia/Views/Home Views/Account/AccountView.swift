//
//  AccountView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.11.24.
//

import SwiftUI

struct AccountView: View {
    
    @State private var user = UserModel.shared
    
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
            UserAccountCard(user: $user)
                .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 16) {
                BTForm(section: generalSection, sectionName: "General")
                BTForm(section: moreSection, sectionName: "More")
            }
        }
        .background(Color.BTBackground)
        .padding(.horizontal, Constants.hPadding)
        .padding(.vertical, Constants.vPadding)
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
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(sectionName)
                .modifier(CustomText(size: 20, font: .semiBold))
            
            VStack {
                VStack(spacing: 20) {
                    ForEach(section.indices, id: \.self) { index in
                        BTFormButton(buttonName: section[index].name, imageName: section[index].image, action: {})
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
                    .modifier(CustomText(size: 16, font: .regular))
                
                Spacer()
                
                Image("Go_Arrow")
                    .tint(Color.black)
            }
        }
    }
}

