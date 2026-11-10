//
//  UserAccountCard.swift
//  BibleTrivia
//

import SwiftUI

struct UserAccountCard: View {
    let profile: UserProfile
    var style: Style = .account

    enum Style {
        /// Name, points/level and a stats strip.
        case account
        /// Name, points/level and a progress bar to the next level.
        case progress
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 10) {
                Image("Avatars/jacob") // TODO: user-chosen avatar
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 60, height: 60)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 8) {
                    Text(profile.name)
                        .applyFont(.semiBold, size: 20, textColor: .white)

                    Text("\(profile.totalPoints) pts | \(profile.level.title)")
                        .applyFont(.medium, size: 14, textColor: .white)

                    if style == .progress {
                        HStack(alignment: .center, spacing: 10) {
                            LinearProgressView(
                                progress: profile.levelProgress,
                                height: 14,
                                showPercentage: false,
                                fillColor: .white,
                                backgroundOpacity: 0.4
                            )
                            if let next = profile.level.next {
                                Text(next.title)
                                    .applyFont(.semiBold, size: 13, textColor: .white)
                                    .fixedSize()
                            }
                        }
                    }
                }
                Spacer()
            }

            if style == .account {
                UserScoreCard(profile: profile)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 20).fill(.btPrimary))
    }
}

struct UserScoreCard: View {
    let profile: UserProfile

    var body: some View {
        HStack(alignment: .center) {
            stat(value: profile.totalPoints, label: "Points")
            divider
            stat(value: profile.currentStreak, label: "Day Streak")
            divider
            stat(value: profile.completedQuizzes, label: "Quizzes")
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 70)
        .background(RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.4)))
    }

    private var divider: some View {
        Text("|")
            .foregroundStyle(.white.opacity(0.7))
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }

    private func stat(value: Int, label: LocalizedStringKey) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text("\(value)")
                .applyFont(.medium, size: 18, textColor: .white)
            Text(label)
                .applyFont(.medium, size: 14, textColor: .white.opacity(0.7))
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack {
        UserAccountCard(profile: SampleData.profile, style: .account)
        UserAccountCard(profile: SampleData.profile, style: .progress)
    }
    .applyViewPaddings()
}
