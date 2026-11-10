//
//  LoadingManager.swift
//  BibleTrivia
//

import SwiftUI
import Lottie

/// Drives the full-screen loading overlay for blocking operations (auth, starting
/// or finishing a quiz). Uses a counter so overlapping operations don't hide the
/// overlay early. Background refreshes should not use this.
@MainActor
@Observable
final class LoadingManager {
    private var activeCount = 0

    var isShowing: Bool { activeCount > 0 }

    func perform<T>(_ operation: () async throws -> T) async rethrows -> T {
        withAnimation { activeCount += 1 }
        defer { withAnimation { activeCount -= 1 } }
        return try await operation()
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            LottieView(animation: .named("Loading"))
                .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                .animationSpeed(0.85)
                .padding(30)
        }
        .accessibilityLabel("Loading")
    }
}

#Preview {
    LoadingView()
}
