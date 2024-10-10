//
//  TopicsView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

struct TopicsView: View {
    @State private var viewModel = TopicsViewViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                Image(systemName: "book.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
        }
        .navigationTitle("Topics")
        .background(Color.BTBackground)
    }
}

#Preview {
    NavigationStack {
        TopicsView()
    }
}
