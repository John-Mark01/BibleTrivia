//
//  EmptyStateView.swift
//  BibleTrivia
//

import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let message: LocalizedStringKey

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 36))
                .foregroundStyle(.btPrimary)
            Text(message)
                .applyFont(.regular, size: 15, textColor: .btLightGray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

/// Centered spinner shown at the bottom of a paginated list.
struct PaginationSpinner: View {
    var body: some View {
        ProgressView()
            .tint(.btPrimary)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .padding(.vertical)
    }
}

#Preview {
    EmptyStateView(systemImage: "checkmark.seal", message: "Nothing here yet")
}
