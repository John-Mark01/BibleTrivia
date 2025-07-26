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
    // Remove @State containerWidth as we'll use GeometryReader differently
    var height: CGFloat = 20
    var progress: Int = 0
    var goal: Int = 0
    var showPercentage: Bool = true
    var fillColor: Color = Color.BTPrimary
    var backgroundColor: Color = .BTLightGray
    var backgroundOpacity: Double = 1.0
    var strokeColor: Color = .BTBlack
    var strokeSize: CGFloat = 1
    
    private func calculateWidth(totalWidth: CGFloat) -> CGFloat {
        return min((totalWidth / CGFloat(goal) * CGFloat(progress)), totalWidth)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 60)
                    .foregroundStyle(backgroundColor.opacity(backgroundOpacity))
                    .frame(width: geometry.size.width, height: height)
                
                // Progress
                ZStack(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 60)
                        .stroke(strokeColor, lineWidth: strokeSize)
                    
                    RoundedRectangle(cornerRadius: 60)
                        .fill(fillColor)
                    
                    if showPercentage {
                        Text("\(Int(Double(progress) / Double(goal) * 100)) %")
                            .applyFont(.medium, size: 15, textColor: .white)
                            .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                            .background(
                                RoundedRectangle(cornerRadius: 60)
                                    .stroke(Color.BTBlack, lineWidth: 2)
                                    .fill(Color.BTDarkGray)
                            )
                    }
                }
                .frame(width: calculateWidth(totalWidth: geometry.size.width), height: height)
            }
        }
        .frame(height: height)
    }
}
struct SimpleLinearProgressView: View {
    @State private var containerWidth: CGFloat = 0
    
    var progress: Int = 0
    var goal: Int = 0
    var progressString: String = ""
    var color: Color = Color.BTPrimary
    
    var maxWidth: Double {
        return min((containerWidth / CGFloat(goal) * CGFloat(progress)), containerWidth)
    }
    
     var body: some View {
     
        VStack {
            HStack {
                Spacer()

                Text(progressString)
                    .applyFont(.regular, size: 10)
            }
            ZStack(alignment: .leading) {
                GeometryReader { geo in
                    
                    RoundedRectangle(cornerRadius: 60)
                        .foregroundStyle(Color.BTProgressBG)
                        .onAppear {
                            containerWidth = geo.size.width
                        }
                        
                }
                ZStack(alignment: .trailing) {
                        
                    RoundedRectangle(cornerRadius: 60)
                        .fill(color)
                    
                }
                .padding(2)
                .frame(minWidth: maxWidth)
                .fixedSize()
            }
            .fixedSize(horizontal: false, vertical: true)

        }
    }
}

#Preview {
    SimpleLinearProgressView(progress: 2, goal: 15)
        .frame(height: 2)
}
