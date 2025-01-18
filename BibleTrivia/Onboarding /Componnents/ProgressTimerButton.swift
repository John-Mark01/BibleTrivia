//
//  ProgressTimerButton.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 18.01.25.
//

import SwiftUI

struct ProgressTimerButton: View {
    @Binding var progress: Int
    @State private var timer: Timer?
    @State private var isRunning = false
    
    var body: some View {
        Button(action: {
            if !isRunning {
                startTimer()
            } else {
                stopTimer()
            }
        }) {
            Text(isRunning ? "Stop" : "Start")
                .padding()
                .background(isRunning ? Color.red : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    private func startTimer() {
        progress = 0
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            if progress < 100 {
                withAnimation {
                    progress += 1
                }
            } else {
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
}
