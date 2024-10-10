//
//  PlayView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

struct PlayView: View {
    @State private var viewModel = PlayViewViewModel()
    var body: some View {
        ScrollView {
            VStack {
                
            }
            .background(Color.BTBackground)
            .navigationTitle("Play")
        }
        
    }
}

#Preview {
    PlayView()
}
