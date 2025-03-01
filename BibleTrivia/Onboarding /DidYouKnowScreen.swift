//
//  DidYouKnowScreen.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 5.02.25.
//

import SwiftUI

struct DidYouKnowScreen: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        
        VStack(alignment: .center, spacing: 40) {
            
            Text("Did You Know?")
                .modifier(CustomText(size: 40, font: .semiBold))
            Text("That 88% of the world's population speaks a language that is not one of the 7 major world languages.")
                .modifier(CustomText(size: 25, font: .medium))
            
            Spacer()
            
            OnboardButton(text: "Continue",
                          action: {dismiss()})
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        DidYouKnowScreen()
    }
}
