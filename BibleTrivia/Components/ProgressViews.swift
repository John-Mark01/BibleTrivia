//
//  CircularProgressView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.10.24.
//

import SwiftUI

struct CircularProgressView: View {
    @Binding var progress: Double 
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    .btLightGray.opacity(0.5),
                    lineWidth: 5
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    .btPrimary,
                    style: StrokeStyle(
                        lineWidth: 5,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                // 1
                .animation(.easeOut, value: progress)
        }
    }
}

struct LinearProgressView: View {
    var height: CGFloat = 20
    var progress: Int
    var goal: Int
    var showPercentage: Bool = true
    var fillColor: Color = .btPrimary
    var backgroundColor: Color = .btProgressBG
    var backgroundOpacity: Double = 1.0
    var strokeColor: Color = .clear
    var strokeSize: CGFloat = 1
    
    private var progressGetter: CGFloat {
        guard progress > 0 else { return 0.7 }
        return CGFloat(progress)
    }
    
    private func calculateWidth(totalWidth: CGFloat) -> CGFloat {
        return min((totalWidth / CGFloat(goal) * progressGetter), totalWidth) - 2
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 60)
                    .stroke(strokeColor, lineWidth: strokeSize)
                    .fill(backgroundColor.opacity(backgroundOpacity))
                    .frame(width: geometry.size.width, height: height)
                
                // Progress fill - only the filled portion
                HStack {
                    RoundedRectangle(cornerRadius: 60)
                        .fill(fillColor)
                        .frame(width: max(calculateWidth(totalWidth: geometry.size.width), 0),height: height - (strokeSize * 2))
                    
//                    Spacer(minLength: 0)
                }
                .padding(strokeSize)
                
//                // Percentage text - positioned based on progress
                if showPercentage {
                    HStack {
                        Spacer()
                        Text("\(Int(Double(progress) / Double(goal) * 100))%")
                            .applyFont(.medium, size: 15, textColor: .white)
                            .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                            .background(
                                RoundedRectangle(cornerRadius: 60)
                                    .stroke(.btBlack, lineWidth: 2)
                                    .fill(.btDarkGray)
                            )
                        
                    }
                    .frame(width: calculateWidth(totalWidth: geometry.size.width), height: height)
                    .fixedSize()
                }
            }
        }
        .frame(height: height)
    }
    
    func setStroke(color: Color, size: CGFloat) -> Self {
        var view = self
        view.strokeColor = color
        view.strokeSize = size
        return view
    }
}

#Preview("LinearProgressView") {
    LinearProgressView(progress: 5, goal: 30)
        .setStroke(color: .btDarkGray, size: 1)
        .applyViewPaddings()
}
