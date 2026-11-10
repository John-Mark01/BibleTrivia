//
//  RootView.swift
//  BibleTrivia
//

import SwiftUI

/// Hosts the single navigation stack and switches between onboarding and the
/// signed-in app based on `AuthManager.state`.
struct RootView: View {
    let app: AppDependencies

    var body: some View {
        @Bindable var router = app.router
        @Bindable var auth = app.auth

        NavigationStack(path: $router.path) {
            Group {
                switch app.auth.state {
                case .unknown:
                    LoadingView()
                case .signedOut:
                    WelcomeView()
                case .signedIn:
                    MainTabView()
                }
            }
            .navigationDestination(for: Router.Destination.self) { $0.view }
        }
        .tint(.btBlack)
        .sheet(isPresented: $auth.isResettingPassword) {
            ResetPasswordView()
                .applyAlertHandling()
        }
        .applyAlertHandling()
        .overlay {
            if app.loading.isShowing {
                LoadingView()
            }
        }
        .inject(app)
        .task { await app.auth.observeAuthChanges() }
        .task(id: app.auth.state) { await authStateChanged(to: app.auth.state) }
        .onOpenURL { url in
            Task { await app.auth.handleDeepLink(url) }
        }
    }

    private func authStateChanged(to state: AuthManager.State) async {
        app.router.popToRoot()
        switch state {
        case .signedIn:
            await app.loadSignedInData()
        case .signedOut:
            app.resetSignedInData()
        case .unknown:
            break
        }
    }
}
