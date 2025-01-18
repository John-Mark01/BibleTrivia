//
//  AvatarView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 18.01.25.
//

import SwiftUI

struct AvatarView: View {
    var avatar: String = "Avatars/jacob"
    var body: some View {
        
        Image(avatar)
            .resizable()
            .frame(width: 140, height: 140)
            .clipShape(.circle)
    }
}

#Preview {
    AvatarView()
}
