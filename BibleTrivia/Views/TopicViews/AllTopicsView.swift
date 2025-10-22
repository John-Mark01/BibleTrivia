//
//  AllTopicsView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 7.11.24.
//

import SwiftUI

struct AllTopicsView: View {
    var topics: [Topic] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Topics")
                .applyFont(.semiBold, size: 16)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(topics, id: \.id) { topic in
                        TopicCard(topic: topic, topicType: .all)
                    }
                }
            }
            .background(.btBackground)
        }
        .applyViewPaddings()
        .navigationTitle("Play")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    
                }) {
                    HStack(spacing: 4) {
                        Image("star")
                        
                        Text("\(326)")
                            .applyFont(.regular, size: 18)
                    }
                }
            }
        }
        
    }
}

