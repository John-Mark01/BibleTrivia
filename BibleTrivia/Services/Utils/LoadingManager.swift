//
//  LoadingManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 27.12.24.
//

import SwiftUI
import Lottie

@Observable class LoadingManager {
    
    var isShowing: Bool = false
    
    static let shared = LoadingManager()
    
    func show() {
        withAnimation {
            isShowing = true
        }
    }
    
    func hide() {
        withAnimation {
            isShowing = false
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                LottieView(animation: .named("Loading"))
                    .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                    .animationSpeed(0.85)
                    .onTapGesture {
                        LoadingManager.shared.hide()
                    }
//                    .overlay(
//                        Text("Loading...")
//                            .foregroundColor(.white)
//                            .modifier(CustomText(size: 20, font: .regular))
//                            .background(
//                                RoundedRectangle(cornerRadius: 14)
//                                    .fill(Color.gray.opacity(0.7))
//                            )
//                            .offset(y: 70)
//                    )
                
            }
            .padding(30)
        }
    }
}

#Preview {
    LoadingView()
}
