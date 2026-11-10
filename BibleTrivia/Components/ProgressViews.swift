//
//  ProgressViews.swift
//  BibleTrivia
//

import SwiftUI

struct CircularProgressView: View {
    /// 0...1
    var progress: Double
    var strokeWidth: CGFloat = 5

    var body: some View {
        ZStack {
            Circle()
                .stroke(.btLightGray.opacity(0.5), lineWidth: strokeWidth)
            Circle()
                .trim(from: 0, to: progress.clamped01)
                .stroke(.btPrimary, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
        .accessibilityElement()
        .accessibilityValue(Text(progress.clamped01, format: .percent.precision(.fractionLength(0))))
    }
}

struct LinearProgressView: View {
    /// 0...1
    var progress: Double
    var height: CGFloat = 20
    var showPercentage: Bool = true
    var fillColor: Color = .btPrimary
    var backgroundColor: Color = .btProgressBG
    var backgroundOpacity: Double = 1.0
    var strokeColor: Color = .clear
    var strokeSize: CGFloat = 1

    private var value: Double { progress.clamped01 }

    var body: some View {
        GeometryReader { geometry in
            let inner = geometry.size.width - strokeSize * 2
            // Keep a visible sliver at 0% so the bar reads as a progress bar.
            let fillWidth = max(inner * value, height - strokeSize * 2)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 60)
                    .stroke(strokeColor, lineWidth: strokeSize)
                    .fill(backgroundColor.opacity(backgroundOpacity))

                RoundedRectangle(cornerRadius: 60)
                    .fill(fillColor)
                    .frame(width: fillWidth, height: height - strokeSize * 2)
                    .padding(strokeSize)
                    .overlay(alignment: .trailing) {
                        if showPercentage {
                            Text(value, format: .percent.precision(.fractionLength(0)))
                                .applyFont(.medium, size: 15, textColor: .white)
                                .padding(.horizontal, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 60)
                                        .stroke(.btBlack, lineWidth: 2)
                                        .fill(.btDarkGray)
                                )
                                .fixedSize()
                        }
                    }
            }
            .animation(.easeOut, value: value)
        }
        .frame(height: height)
        .accessibilityElement()
        .accessibilityValue(Text(value, format: .percent.precision(.fractionLength(0))))
    }

    func setStroke(color: Color, size: CGFloat) -> Self {
        var view = self
        view.strokeColor = color
        view.strokeSize = size
        return view
    }
}

private extension Double {
    var clamped01: Double { isFinite ? Swift.min(Swift.max(self, 0), 1) : 0 }
}

#Preview("Circular") {
    HStack {
        CircularProgressView(progress: 0)
        CircularProgressView(progress: 1.0 / 3)
        CircularProgressView(progress: 1)
    }
    .frame(height: 40)
    .applyViewPaddings()
}

#Preview("Linear") {
    VStack(spacing: 20) {
        LinearProgressView(progress: 0)
        LinearProgressView(progress: 0.4)
            .setStroke(color: .btDarkGray, size: 1)
        LinearProgressView(progress: 1, height: 14, showPercentage: false)
    }
    .applyViewPaddings()
}
