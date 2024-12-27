//
//  MyProgressView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 16.12.24.
//

import SwiftUI

struct MyProgressView: View {
    @State private var user = UserModel.shared
    var body: some View {
        ScrollView {
            
            VStack {
                UserAccountCard(user: $user, viewUse: .myProgress)
                    .frame(height: 50)
                
            }
            .navigationTitle("My Progress")
            .padding(.horizontal, Constants.hPadding)
            .padding(.top, Constants.topPadding)
        }
    }
}

#Preview {
    NavigationStack {
        MyProgressView()
    }
}
