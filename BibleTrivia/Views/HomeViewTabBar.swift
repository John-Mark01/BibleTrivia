//
//  HomeViewTabBar.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

struct HomeViewTabBar: View {
    @State private var selectedTab: Int = 1
    var body: some View {
        TabView(selection: $selectedTab) {
            
            Tab("Home", systemImage: "house", value: 1) {
                NavigationView {
                    HomeView()
                        .navigationTitle("Home")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            
            Tab("Play", systemImage: "play", value: 2) {
                NavigationView {
                    PlayView()
                }
            }
            
            Tab("Topics", systemImage: "book", value: 3) {
                NavigationView {
                    TopicsView()
                }
            }
        }
        .tint(Color.BTPrimary)
    }
}

#Preview {
    NavigationStack {
        HomeViewTabBar()
    }
}
