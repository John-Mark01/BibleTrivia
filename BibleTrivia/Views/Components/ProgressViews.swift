//
//  CircularProgressView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.10.24.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double = 0.0
    
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
    @State private var containerWidth: CGFloat = 0
    
    var progress: Int = 0
    var goal: Int = 0
    
    var maxWidth: Double {
        return min((containerWidth / CGFloat(goal) * CGFloat(progress)), containerWidth)
    }
    
     var body: some View {
     
        VStack {
            ZStack(alignment: .leading) {
                GeometryReader { geo in
                    
                    RoundedRectangle(cornerRadius: 60)
                        .foregroundStyle(Color.BTLightGray)
                        .onAppear {
                            containerWidth = geo.size.width
                        }
                        
                }
                ZStack(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 60)
                        .stroke(Color.BTBlack, lineWidth: 1.5)
                        
                    RoundedRectangle(cornerRadius: 60)
                        .fill(Color.BTPrimary)
                    
                    Text("\(Int(Double(progress) / Double(goal) * 100)) %")
                        .foregroundStyle(Color.white)
                        .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                        .modifier(CustomText(size: 15, font: .heading))
                        .background(
                            RoundedRectangle(cornerRadius: 60)
                                .stroke(Color.BTBlack, lineWidth: 1)
                                .fill(Color.BTDarkGray)
                        )
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
    LinearProgressView(progress: 14, goal: 15)
        .frame(height: 2)
}
