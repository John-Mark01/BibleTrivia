//
//  TopicsView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

struct TopicsView: View {
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Spacer()
                Image(systemName: "book.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
        }
        .applyViewPaddings()
        .applyBackground()
        .navigationTitle("Topics")
    }
}

#Preview {
    NavigationStack {
        TopicsView()
    }
}
