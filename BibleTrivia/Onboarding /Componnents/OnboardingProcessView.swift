//
//  OnboardingProcessView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 18.01.25.
//

import SwiftUI

struct OnboardingProcessView: View {
    
    var icon: String = "Arrow"
    var iconColor: Color = .white
    var direction: LayoutDirection = .leftToRight
    let action: () -> Void
    @State private var progress: Int = 0
    
    var body: some View {
        HStack(spacing: 15) {
            
            Button(action: {
                action()
            }) {
                Image(icon)
                    .resizable()
                    .frame(width: 25, height: 18)
                    .layoutDirectionBehavior(.mirrors(in: direction))
            }
            
            LinearProgressView(height: 23,
                               progress: progress,
                               goal: 100,
                               showPercentage: false,
                               backgroundColor: .BTLightGray.opacity(0.5),
                               backgroundOpacity: 0.4,
                               strokeColor: .BTPrimary, strokeSize: 1)
            
            
        }
        
        ProgressTimerButton(progress: $progress)
            .padding()
    }
}

#Preview {
    OnboardingProcessView(action: {})
}
