//
//  QuizViewToolbar.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 16.10.24.
//

import SwiftUI

struct QuizViewToolbar: View {
    var body: some View {
        HStack {
            ProgressView(value: 0.3)
                .progressViewStyle(.linear)
                .tint(.btPrimary)
                .scaleEffect(x: 1, y: 3, anchor: .center)
                
            
            Spacer()
            
            Image("close")
                
        }
    }
}

#Preview {
    QuizViewToolbar()
}
