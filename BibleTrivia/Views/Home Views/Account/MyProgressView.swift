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
        ScrollView(showsIndicators: false) {
            VStack {
                UserAccountCard(user: userManager.user, viewUse: .myProgress)
                
            }
            .applyViewPaddings()
            .navigationTitle("My Progress")
        }
    }
}

#Preview {
    PreviewEnvironmentView {
        MyProgressView()
    }
}
