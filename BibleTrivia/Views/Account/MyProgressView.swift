//
//  MyProgressView.swift
//  BibleTrivia
//

import SwiftUI

struct MyProgressView: View {
    @Environment(UserStore.self) private var userStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Constants.vStackSpacing + 8) {
                if let profile = userStore.profile {
                    UserAccountCard(profile: profile, style: .progress)

                    BTContentBox {
                        HStack(spacing: Constants.vStackSpacing) {
                            Image("Icon/bulzai")
                                .accessibilityHidden(true)
                            Text(motivation(for: profile))
                                .applyFont(.medium, size: 12, textColor: .btPrimary)
                            Spacer()
                        }
                    }

                    HStack {
                        StatBox(image: "Icon/quiz_roulette", title: "Total Quizzes", value: profile.completedQuizzes)
                        Spacer(minLength: 25)
                        StatBox(image: "Icon/quiz_score", title: "Total Points", value: profile.totalPoints)
                    }
                }

                LazyVStack(alignment: .leading, spacing: Constants.vStackSpacing) {
                    Text("Quizzes History")
                        .applyFont(.medium, size: 16, textColor: .btBlack)

                    if userStore.completed.items.isEmpty && !userStore.completed.isLoading {
                        EmptyStateView(systemImage: "list.bullet.clipboard", message: "Completed quizzes will show up here.")
                    }

                    ForEach(userStore.completed.items) { attempt in
                        CompletedQuizRow(attempt: attempt)
                            .task { await userStore.loadMoreCompletedIfNeeded(after: attempt) }
                    }

                    if userStore.completed.isLoading {
                        PaginationSpinner()
                    }
                }
            }
            .applyViewPaddings(.vertical)
        }
        .refreshable {
            async let profile: Void = userStore.refreshProfile()
            async let completed: Void = userStore.loadCompleted(reset: true)
            _ = await (profile, completed)
        }
        .task { await userStore.loadCompleted(reset: true) }
        .navigationTitle("My Progress")
        .navigationBarTitleDisplayMode(.large)
        .applyViewPaddings(.horizontal)
        .applyBackground()
    }

    private func motivation(for profile: UserProfile) -> String {
        guard let next = profile.nextLevelMinPoints, let nextLevel = profile.level.next else {
            return "You've reached the highest level. Amazing work!"
        }
        return "\(next - profile.totalPoints) more points to become a \(nextLevel.title). Keep going!"
    }
}

private struct StatBox: View {
    let image: String
    let title: LocalizedStringKey
    let value: Int

    var body: some View {
        BTContentBox {
            VStack(alignment: .center, spacing: Constants.vStackSpacing) {
                Image(image)
                    .accessibilityHidden(true)
                Text(title)
                    .applyFont(.medium, size: 14, textColor: .btBlack)
                Text("\(value)")
                    .applyFont(.semiBold, size: 20, textColor: .btPrimary)
                    .padding(.top, -8)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PreviewEnvironment {
        MyProgressView()
    }
}
