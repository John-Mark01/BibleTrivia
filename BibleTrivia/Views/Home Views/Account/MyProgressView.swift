//
//  MyProgressView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 16.12.24.
//

import SwiftUI

struct MyProgressView: View {
    @Environment(UserStore.self) var userStore
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                UserAccountCard(user: userStore.user, viewUse: .myProgress)
                
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
