//
//  AccountView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.11.24.
//

import SwiftUI

struct AccountView: View {
    @Environment(Router.self) var router
    @Environment(UserManager.self) var userManager
    
    @State private var generalSection: [SectionModel] = [
        SectionModel(name: "My Progress", image: "progress", action: {}),
        SectionModel(name: "Friends", image: "friends", action: {})
    ]
    
    private var moreSection: [SectionModel] {
        [
        SectionModel(name: "Account Information", image: "Account", action: {}),
        SectionModel(name: "Notifications", image: "notifications", action: {}),
        SectionModel(name: "Settings", image: "settings", action: {}),
        SectionModel(name: "Logout", image: "logout", action: logout)
        ]
    }
    var body: some View {
        ScrollView {
            UserAccountCard(user: userManager.user, viewUse: .account)
                .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 16) {
                BTForm(section: generalSection, sectionName: "General")
                BTForm(section: moreSection, sectionName: "More")
            }
        }
        .navigationTitle("Account")
        .applyViewPaddings()
        .applyBackground()
    }
    
    private func logout() {
        Task {
            await userManager.signOut() {
                router.popToRoot()
            }
        }
    }
}

#Preview {
    NavigationView {
        AccountView()
    }
    .environment(UserManager(supabase: .init(), alertManager: .shared))
    .environment(Router.shared)
}

struct BTForm: View {
    var section: [SectionModel]
    var sectionName: String
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(sectionName)
                .applyFont(.semiBold, size: 20)
            
            VStack {
                VStack(spacing: 20) {
                    ForEach(section.indices, id: \.self) { index in
                        BTFormButton(section: section[index])
                        
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
    var section: SectionModel
    
    var body: some View {
        
        Button(action: {
            withAnimation {
                section.action()
            }
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image(section.image)
                
                Text(section.name)
                    .applyFont(.regular, size: 16)
                
                Spacer()
                
                Image("Go_Arrow")
                    .tint(Color.black)
            }
        }
    }
}

