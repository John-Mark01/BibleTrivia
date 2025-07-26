//
//  MyProgressView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 16.12.24.
//

import SwiftUI

struct MyProgressView: View {
    @Environment(UserManager.self) var userManager
    var body: some View {
        ScrollView {
            
            VStack {
                UserAccountCard(user: userManager.user, viewUse: .myProgress)
                    .frame(height: 50)
                
            }
            .navigationTitle("My Progress")
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.top, Constants.topPadding)
        }
    }
}

#Preview {
    NavigationStack {
        MyProgressView()
    }
}
