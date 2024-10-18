//
//  SplashScreen.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 10.10.24.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive: Bool = false
    @State private var size = 0.8
    @State private var opacity = 0.3
    
    var body: some View {
        
        if isActive {
            HomeViewTabBar()
        } else {
            
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.BTPrimary, Color.BTSecondary]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                VStack {
                    Image("Logo_Splash")
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 1.2
                        self.opacity = 1.0
                    }
                }
                
            }
            .ignoresSafeArea(.all)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}
