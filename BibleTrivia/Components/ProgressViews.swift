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
                    Color.BTLightGray.opacity(0.5),
                    lineWidth: 5
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.BTPrimary,
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
    var fillColor: Color = Color.BTPrimary
    var backgroundColor: Color = .BTLightGray
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
                    .foregroundStyle(backgroundColor.opacity(backgroundOpacity))
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
                                    .stroke(Color.BTBlack, lineWidth: 2)
                                    .fill(Color.BTDarkGray)
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
        .setStroke(color: .BTDarkGray, size: 1)
        .applyViewPaddings()
}

struct SimpleLinearProgressView: View {
    @State private var containerWidth: CGFloat = 0
    
    var progress: Int = 0
    var goal: Int = 0
    var progressString: String = ""
    var progressColor: Color = Color.BTPrimary
    var backgroundColor: Color = Color.BTProgressBG
    
    var maxWidth: Double {
        return min((containerWidth / CGFloat(goal) * CGFloat(progress)), containerWidth)
    }
    
    var body: some View {
        
        VStack {
            //            HStack {
            //                Spacer()
            //
            //                Text(progressString)
            //                    .applyFont(.regular, size: 10)
            //            }
            //
            ZStack(alignment: .leading) {
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 60)
                        .stroke(Color.black, lineWidth: 0.5)
                        .foregroundStyle(backgroundColor)
                        .onAppear {
                            containerWidth = geometry.size.width
                        }
                }
                
                ZStack(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 60)
                        .fill(progressColor)
                }
                .padding(4)
                .frame(minWidth: maxWidth)
                .fixedSize()
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview("SimpleLinearProgressView") {
    VStack {
        SimpleLinearProgressView(progress: 100, goal: 100)
            .frame(height: 20)
    }
    .applyViewPaddings()
}
