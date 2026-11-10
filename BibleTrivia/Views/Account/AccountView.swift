//
//  AccountView.swift
//  BibleTrivia
//

import SwiftUI

struct AccountView: View {
    @Environment(Router.self) private var router
    @Environment(UserStore.self) private var userStore
    @Environment(AuthManager.self) private var authManager
    @Environment(AlertManager.self) private var alertManager

    private var generalSection: [SectionModel] {
        [
            SectionModel(name: "My Progress", image: "progress") { router.navigate(to: .myProgress) },
            SectionModel(name: "Friends", image: "friends") { alertManager.showFeatureComingSoonAlert(for: "Friends") },
        ]
    }

    private var moreSection: [SectionModel] {
        [
            SectionModel(name: "Notifications", image: "notifications") { alertManager.showFeatureComingSoonAlert(for: "Notifications") },
            SectionModel(name: "Logout", image: "logout") { Task { await authManager.signOut() } },
            SectionModel(name: "Delete Account", image: "Account", action: confirmDeleteAccount),
        ]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            if let profile = userStore.profile {
                UserAccountCard(profile: profile, style: .account)
                    .padding(.bottom, 20)
            }

            VStack(alignment: .leading, spacing: 16) {
                BTForm(section: generalSection, sectionName: "General")
                BTForm(section: moreSection, sectionName: "More")
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .applyViewPaddings()
        .applyBackground()
    }

    private func confirmDeleteAccount() {
        alertManager.showAlert(
            type: .warning,
            title: "Delete Account?",
            message: "This permanently deletes your account, progress and points. This can't be undone.",
            buttonText: "Delete Forever"
        ) {
            Task { await authManager.deleteAccount() }
        }
    }
}

struct BTForm: View {
    let section: [SectionModel]
    let sectionName: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading) {
            Text(sectionName)
                .applyFont(.semiBold, size: 20)

            VStack(spacing: 20) {
                ForEach(section.indices, id: \.self) { index in
                    BTFormButton(section: section[index])

                    if index < section.count - 1 {
                        Divider()
                    }
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.btStroke, lineWidth: 1)
            )
            .tint(.btBlack)
        }
    }
}

struct BTFormButton: View {
    let section: SectionModel

    var body: some View {
        Button(action: section.action) {
            HStack(alignment: .center, spacing: 10) {
                Image(section.image)
                    .accessibilityHidden(true)

                Text(section.name)
                    .applyFont(.regular, size: 16)

                Spacer()

                Image("Icon/navigation_arrow")
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    PreviewEnvironment {
        AccountView()
    }
}
